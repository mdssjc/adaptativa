#lang racket/base

(require (for-syntax racket/base
                     syntax/parse)
         (only-in lang/htdp-beginner [#%module-begin bsl-mb])
         (only-in test-engine/test-engine current-test-object test-object-successful-tests)
         racket/string
         "../tracker/state.rkt"
         "../tracker/config.rkt"
         "../tracker/logger.rkt"
         "feedback.rkt"
         "syntax-macros.rkt")

(provide (rename-out [adaptativa-module-begin #%module-begin])
         compute-execution-points!
         running-in-drracket?)

(define (compute-execution-points! has-var? has-func? has-cond? has-rep? [source-path #f] [from-macro? #f])
  (define in-drracket? (running-in-drracket?))
  (define student (get-current-student))

  (define-values (authorized? exec-path exec-hash) (consume-execution-auth!))

  (define target-path
    (cond
      [(and (string? exec-path) (not (string=? exec-path ""))) exec-path]
      [(and (string? source-path) (not (string=? source-path ""))) source-path]
      [else "sem-titulo.rkt"]))

  (define is-test-or-system? (system-or-test-path? (format "~a" target-path)))

  (define should-score?
    (cond
      [is-test-or-system? #f]
      [in-drracket? authorized?]
      [from-macro? #f]
      [else #t]))

  (when should-score?
    (define cfg (load-teacher-config))
    (define pts-var (hash-ref cfg 'pts_variavel 1))
    (define pts-func (hash-ref cfg 'pts_funcao 2))
    (define pts-cond (hash-ref cfg 'pts_condicional 3))
    (define pts-rep (hash-ref cfg 'pts_repeticao 3))
    (define pts-test (hash-ref cfg 'pts_teste 2))

    (define file-pts 0)
    (when has-var? (set! file-pts (+ file-pts pts-var)))
    (when has-func? (set! file-pts (+ file-pts pts-func)))
    (when has-cond? (set! file-pts (+ file-pts pts-cond)))
    (when has-rep? (set! file-pts (+ file-pts pts-rep)))

    (define test-successes 0)
    (with-handlers ([exn:fail? (lambda (e) (void))])
      (define to (current-test-object))
      (when to
        (set! test-successes (length (test-object-successful-tests to)))
        (when (> test-successes 0)
          (set! file-pts (+ file-pts (* test-successes pts-test))))))

    (define details
      (hasheq 'tem_variavel (if has-var? #t #f)
              'tem_funcao (if has-func? #t #f)
              'tem_condicional (if has-cond? #t #f)
              'tem_repeticao (if has-rep? #t #f)
              'testes_aprovados test-successes
              'hash_codigo (or exec-hash "")))

    (record-student-file-activity! student target-path file-pts details)))

(define-syntax (adaptativa-module-begin stx)
  (syntax-case stx ()
    [(_ form ...)
     (let ()
       (define forms (syntax->list #'(form ...)))
       (define src (syntax-source stx))
       (define src-str
         (cond
           [(path? src) (path->string src)]
           [(string? src) src]
           [else #f]))

       (define (has-variable-def?)
         (for/or ([f (in-list forms)])
           (let loop ([s f])
             (syntax-case s ()
               [(head arg ...)
                (and (identifier? #'head)
                     (or (free-identifier=? #'head (datum->syntax #'head 'defina))
                         (and (free-identifier=? #'head (datum->syntax #'head 'definir))
                              (let ([args (syntax->list #'(arg ...))])
                                (and (pair? args)
                                     (not (pair? (syntax-e (car args)))))))))
                #t]
               [_
                (let ([subs (and (syntax? s) (syntax->list s))])
                  (and subs
                       (for/or ([sub (in-list subs)])
                         (loop sub))))]))))

       (define (has-function-def?)
         (for/or ([f (in-list forms)])
           (let loop ([s f])
             (syntax-case s ()
               [(head (fn-name param ...) body ...)
                (and (identifier? #'head)
                     (free-identifier=? #'head (datum->syntax #'head 'definir)))
                #t]
               [_
                (let ([subs (and (syntax? s) (syntax->list s))])
                  (and subs
                       (for/or ([sub (in-list subs)])
                         (loop sub))))]))))

       (define (contains-identifier? syms)
         (for/or ([f (in-list forms)])
           (let loop ([s f])
             (cond
               [(and (identifier? s) (memq (syntax-e s) syms)) #t]
               [(syntax? s) (loop (syntax-e s))]
               [(pair? s) (or (loop (car s)) (loop (cdr s)))]
               [else #f]))))

       (define has-var (if (has-variable-def?) #t #f))
       (define has-func (if (has-function-def?) #t #f))
       (define has-cond (contains-identifier? '(se escolha if cond)))
       (define has-rep (contains-identifier? '(repetir)))
       (define uses-define? (contains-identifier? '(define)))
       (define uses-check-expect? (contains-identifier? '(check-expect)))

       #`(bsl-mb
          #,@(if uses-define?
                 (list #`(void (check-syntactic-level! 2 'define "definir" '#,src-str)))
                 '())
          #,@(if uses-check-expect?
                 (list #`(void (check-syntactic-level! 2 'check-expect "verificar-resultado" '#,src-str)))
                 '())
          form ...
          (void (compute-execution-points! '#,has-var '#,has-func '#,has-cond '#,has-rep '#,src-str #t))))]))
