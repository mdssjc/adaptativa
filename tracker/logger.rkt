#lang racket/base

(require racket/file
         racket/path
         racket/string
         json
         "timer.rkt")

(provide current-data-dir
         log-event!
         get-data-dir-path
         get-log-file-path
         write-json-atomic!
         file-stat-stamp)

(define current-data-dir (make-parameter #f))

(define (get-data-dir-path)
  (define param-dir (current-data-dir))
  (define env-dir (getenv "ADAPTATIVA_DATA_DIR"))
  (define dir
    (cond
      [(and param-dir (path-string? param-dir))
       (if (path? param-dir) param-dir (string->path param-dir))]
      [(and (string? env-dir) (non-empty-string? (string-trim env-dir)))
       (string->path (string-trim env-dir))]
      [else
       (build-path (find-system-path 'pref-dir) "adaptativa")]))
  (unless (directory-exists? dir)
    (make-directory* dir))
  dir)

(define (get-log-file-path)
  (build-path (get-data-dir-path) "historico-eventos.jsonl"))

(define (file-stat-stamp path)
  (with-handlers ([exn:fail? (lambda (e) #f)])
    (define st (file-or-directory-stat path))
    (list (hash-ref st 'modify-time-seconds 0)
          (hash-ref st 'modify-time-nanoseconds 0)
          (hash-ref st 'size 0))))

(define (write-json-atomic! path data)
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (eprintf "[adaptativa] Erro ao gravar arquivo ~a: ~a~n" path (exn-message e))
                     #f)])
    (define dir (or (path-only path) (current-directory)))
    (unless (directory-exists? dir)
      (make-directory* dir))
    (define tmp-path (make-temporary-file "adaptativa-~a.tmp" #f dir))
    (with-handlers ([exn:fail?
                     (lambda (e)
                       (with-handlers ([exn:fail? void])
                         (when (file-exists? tmp-path)
                           (delete-file tmp-path)))
                       (raise e))])
      (display-to-file (jsexpr->string data) tmp-path #:exists 'replace)
      (rename-file-or-directory tmp-path path #t))
    #t))

(define log-mutex (make-semaphore 1))

(define (log-event! student-id event-type category level details)
  (define event
    (hasheq 'timestamp (get-timestamp-iso8601)
            'aluno (or student-id "aluno-anonimo")
            'tipo (symbol->string event-type)
            'categoria (symbol->string category)
            'nivel level
            'detalhes (if (string? details) details (format "~a" details))))
  (call-with-semaphore
   log-mutex
   (lambda ()
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "[adaptativa] Erro ao gravar log de eventos: ~a~n" (exn-message e)))])
       (define file (get-log-file-path))
       (define json-line (jsexpr->string event))
       (display-to-file (string-append json-line "\n")
                        file
                        #:exists 'append)))))
