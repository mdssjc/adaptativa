#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/file
         racket/date
         racket/string
         racket/path
         racket/list
         json
         "logger.rkt"
         "timer.rkt"
         "config.rkt")

(provide aluno
         set-current-student!
         get-current-student
         get-student-level
         get-student-syntactic-level
         get-student-points
         record-student-error!
         record-student-success!
         add-student-points!
         load-profile
         save-profile!
         clear-profile-cache!
         normalize-file-path
         authorize-next-execution!
         consume-execution-auth!
         execution-authorized?
         clear-execution-auth!
         sanitize-student-filename
         update-student-last-hash!
         record-student-file-activity!
         get-student-files
         get-student-categories
         recalculate-points-by-categories
         list-all-students
         register-new-student!
         reset-student-progress!
         remove-student!
         system-or-test-path?)

(define (get-active-session-path)
  (build-path (get-data-dir-path) "sessao-ativa.json"))

(define CACHE-CURRENT-STUDENT #f)
(define CACHE-SESSION-KEY #f)

(define (get-current-student)
  (define path (get-active-session-path))
  (if (file-exists? path)
      (let* ([stamp (file-stat-stamp path)]
             [cache-key (cons (path->string path) stamp)])
        (if (and CACHE-CURRENT-STUDENT stamp (equal? cache-key CACHE-SESSION-KEY))
            CACHE-CURRENT-STUDENT
            (let ([id (with-handlers ([exn:fail?
                                       (lambda (e)
                                         (eprintf "[adaptativa] Aviso ao ler sessao-ativa.json: ~a~n" (exn-message e))
                                         "aluno-anonimo")])
                        (define j (string->jsexpr (file->string path)))
                        (hash-ref j 'aluno "aluno-anonimo"))])
              (set! CACHE-CURRENT-STUDENT id)
              (set! CACHE-SESSION-KEY cache-key)
              id)))
      "aluno-anonimo"))

(define (set-current-student! name-or-id)
  (define id (if (string? name-or-id) name-or-id (format "~a" name-or-id)))
  (set! CACHE-CURRENT-STUDENT id)
  (define path (get-active-session-path))
  (when (write-json-atomic! path (hasheq 'aluno id))
    (set! CACHE-SESSION-KEY (cons (path->string path) (file-stat-stamp path))))
  (load-or-init-profile! id)
  (log-event! id 'sessao 'inicializacao 1 "Sessão ativada no ambiente")
  id)

(define-syntax (aluno stx)
  (syntax-parse stx
    [(_ id:str)
     #'(set-current-student! id)]
    [(_ id:expr)
     #'(set-current-student! id)]))

(define (sanitize-student-filename student-id)
  (define raw (string-trim (if (string? student-id) student-id (format "~a" student-id))))
  (define no-dots (regexp-replace* #px"\\.\\." raw "_"))
  (define clean (regexp-replace* #px"[/\\\\:*?\"<>|\u0000-\u001f]" no-dots "_"))
  (define trimmed (string-trim clean "."))
  (if (non-empty-string? trimmed) trimmed "aluno-anonimo"))

(define (get-profile-path student-id)
  (build-path (get-data-dir-path) (format "~a-perfil.json" (sanitize-student-filename student-id))))

(define (default-profile student-id)
  (hasheq 'aluno student-id
          'erros (hasheq)
          'total_sucessos 0
          'bonus_pontos 0
          'total_erros 0
          'ultimo_hash ""
          'arquivos (hasheq)))

(define (get-execution-auth-path)
  (build-path (get-data-dir-path) "autorizacao-execucao.json"))

(define (authorize-next-execution! [file-path ""] [code-hash ""])
  (define data (hasheq 'autorizado #t
                       'timestamp (current-seconds)
                       'caminho (if (string? file-path) file-path (format "~a" file-path))
                       'hash (if (string? code-hash) code-hash (format "~a" code-hash))))
  (write-json-atomic! (get-execution-auth-path) data))

(define (execution-authorized?)
  (define path (get-execution-auth-path))
  (if (file-exists? path)
      (with-handlers ([exn:fail? (lambda (e) #f)])
        (define j (string->jsexpr (file->string path)))
        (define authorized? (hash-ref j 'autorizado #f))
        (define ts (hash-ref j 'timestamp 0))
        (and authorized? (<= (- (current-seconds) ts) 30)))
      #f))

(define (clear-execution-auth!)
  (define path (get-execution-auth-path))
  (when (file-exists? path)
    (write-json-atomic! path (hasheq 'autorizado #f 'timestamp 0 'caminho "" 'hash ""))))

(define (consume-execution-auth!)
  (define path (get-execution-auth-path))
  (if (file-exists? path)
      (with-handlers ([exn:fail? (lambda (e) (values #f "" ""))])
        (define j (string->jsexpr (file->string path)))
        (write-json-atomic! path (hasheq 'autorizado #f 'timestamp 0 'caminho "" 'hash ""))
        (define authorized? (hash-ref j 'autorizado #f))
        (define ts (hash-ref j 'timestamp 0))
        (define c (hash-ref j 'caminho ""))
        (define h (hash-ref j 'hash ""))
        (define now (current-seconds))
        (if (and authorized? (<= (- now ts) 30))
            (values #t c h)
            (values #f "" "")))
      (values #f "" "")))

(define (update-student-last-hash! student-id hash-str)
  (define id (or student-id (get-current-student)))
  (define profile (load-profile id))
  (define new-profile (hash-set profile 'ultimo_hash (if (string? hash-str) hash-str (format "~a" hash-str))))
  (save-profile! id new-profile))

(define (normalize-file-path path-str)
  (with-handlers ([exn:fail? (lambda (e) (string-downcase (format "~a" path-str)))])
    (cond
      [(and (string? path-str) (non-empty-string? path-str))
       (define p (string->path path-str))
       (define canonical
         (cond
           [(file-exists? p) (simple-form-path p)]
           [else (simplify-path (cleanse-path (path->complete-path p)))]))
       (string-downcase (string-replace (path->string canonical) "\\" "/"))]
      [else "sem-titulo.rkt"])))

(define PKG-ROOT-PATH
  (with-handlers ([exn:fail? (lambda (e) #f)])
    (define c-path (collection-file-path "info.rkt" "adaptativa"))
    (define-values (base _ __) (split-path c-path))
    (string-downcase (string-replace (path->string (simplify-path base)) "\\" "/"))))

(define (system-or-test-path? path-str)
  (and (string? path-str)
       (let ([p (string-downcase (string-replace path-str "\\" "/"))])
         (or (and PKG-ROOT-PATH
                  (or (string-prefix? p (string-append PKG-ROOT-PATH "tests/"))
                      (string-prefix? p (string-append PKG-ROOT-PATH "examples/"))))
             (regexp-match? #px"^(?:tests|examples)/" p)
             (regexp-match? #px"(?:^|/)(?:suite-test|test-lessons-and-config|test-score-guard|test-dynamic-examples|test-student-persistence|test-teacher-report|test-error-definition|test-error-if|demo-adaptability-levels|demo-external-progression)[.]rkt$" p)))))

(define (record-student-file-activity! student-id file-path file-points file-details)
  (define id (or student-id (get-current-student)))
  (if (system-or-test-path? (format "~a" file-path))
      (get-student-points id)
      (let ()
        (define profile (load-profile id #t))
        (define files-map (hash-ref profile 'arquivos (hasheq)))

        (define simple-name
          (with-handlers ([exn:fail? (lambda (e) (format "~a" file-path))])
            (if (and (string? file-path) (non-empty-string? file-path))
                (let-values ([(base name dir?) (split-path (string->path file-path))])
                  (path->string name))
                "sem-titulo.rkt")))

        (define norm-path (normalize-file-path file-path))
        (define file-key (string->symbol norm-path))

        (define file-record
          (hasheq 'caminho norm-path
                  'nome_arquivo simple-name
                  'pontos file-points
                  'timestamp (get-timestamp-ptbr)
                  'detalhes file-details))

        (define clean-map
          (for/hash ([(k reg) (in-hash files-map)]
                     #:unless (or (equal? k file-key)
                                  (equal? (normalize-file-path (hash-ref reg 'caminho "")) norm-path)
                                  (and (equal? (hash-ref reg 'nome_arquivo "") simple-name)
                                       (equal? (normalize-file-path (hash-ref reg 'caminho "")) norm-path))))
            (values k reg)))

        (define new-files (hash-set clean-map file-key file-record))

        (define-values (cat-points categories-map)
          (recalculate-points-by-categories new-files))
        (define bonus (hash-ref profile 'bonus_pontos 0))
        (define new-total-points (+ cat-points bonus))

        (define new-profile
          (hash-set (hash-set (hash-set profile 'arquivos new-files)
                              'total_sucessos new-total-points)
                    'categorias_conquistadas categories-map))
        (save-profile! id new-profile)

        (log-event! id 'sucesso 'arquivo 1
                    (format "Arquivo '~a': ~a pontos (Total global por categorias: ~a pts)"
                            simple-name file-points new-total-points))
        new-total-points)))

(define (recalculate-points-by-categories files-map [cfg-manual #f])
  (define cfg (or cfg-manual (load-teacher-config)))

  (define has-var?
    (for/or ([(_ reg) (in-hash files-map)])
      (define d (hash-ref reg 'detalhes (hasheq)))
      (and (hash-ref d 'tem_variavel #f) #t)))

  (define has-func?
    (for/or ([(_ reg) (in-hash files-map)])
      (define d (hash-ref reg 'detalhes (hasheq)))
      (and (hash-ref d 'tem_funcao #f) #t)))

  (define has-cond?
    (for/or ([(_ reg) (in-hash files-map)])
      (define d (hash-ref reg 'detalhes (hasheq)))
      (and (hash-ref d 'tem_condicional #f) #t)))

  (define has-rep?
    (for/or ([(_ reg) (in-hash files-map)])
      (define d (hash-ref reg 'detalhes (hasheq)))
      (and (hash-ref d 'tem_repeticao #f) #t)))

  (define has-test?
    (for/or ([(_ reg) (in-hash files-map)])
      (define d (hash-ref reg 'detalhes (hasheq)))
      (or (> (hash-ref d 'testes_aprovados 0) 0)
          (and (hash-ref d 'tem_teste #f) #t))))

  (define total 0)
  (when has-var? (set! total (+ total (hash-ref cfg 'pts_variavel 1))))
  (when has-func? (set! total (+ total (hash-ref cfg 'pts_funcao 2))))
  (when has-cond? (set! total (+ total (hash-ref cfg 'pts_condicional 3))))
  (when has-rep? (set! total (+ total (hash-ref cfg 'pts_repeticao 3))))
  (when has-test? (set! total (+ total (hash-ref cfg 'pts_teste 2))))

  (values total
          (hasheq 'variavel (if has-var? #t #f)
                  'funcao (if has-func? #t #f)
                  'condicional (if has-cond? #t #f)
                  'repeticao (if has-rep? #t #f)
                  'teste (if has-test? #t #f))))

(define (get-student-categories [student-id #f])
  (define profile (load-profile (or student-id (get-current-student))))
  (define-values (total cats)
    (recalculate-points-by-categories (hash-ref profile 'arquivos (hasheq))))
  cats)

(define (get-student-files [student-id #f])
  (define profile (load-profile (or student-id (get-current-student))))
  (hash-ref profile 'arquivos (hasheq)))

(define PROFILES-CACHE-TABLE (make-hash))

(define (clear-profile-cache! [student-id #f])
  (set! CACHE-CURRENT-STUDENT #f)
  (set! CACHE-SESSION-KEY #f)
  (if student-id
      (hash-remove! PROFILES-CACHE-TABLE student-id)
      (hash-clear! PROFILES-CACHE-TABLE)))

(define (clean-test-files-from-profile data)
  (if (hash? data)
      (let ([arquivos (hash-ref data 'arquivos #f)])
        (if (hash? arquivos)
            (let ([filtered (for/hash ([(k reg) (in-hash arquivos)]
                                       #:unless (or (system-or-test-path? (format "~a" k))
                                                    (system-or-test-path? (format "~a" (hash-ref reg 'caminho "")))
                                                    (system-or-test-path? (format "~a" (hash-ref reg 'nome_arquivo "")))))
                              (values k reg))])
              (if (= (hash-count filtered) (hash-count arquivos))
                  data
                  (let-values ([(cat-points categories-map)
                                (recalculate-points-by-categories filtered)])
                    (define bonus (hash-ref data 'bonus_pontos 0))
                    (hash-set (hash-set (hash-set data 'arquivos filtered)
                                        'total_sucessos (+ cat-points bonus))
                              'categorias_conquistadas categories-map))))
            data))
      data))

(define (load-profile student-id [force? #f])
  (define path (get-profile-path student-id))
  (if (file-exists? path)
      (let* ([stamp (file-stat-stamp path)]
             [cache-key (cons (path->string path) stamp)]
             [cached-entry (hash-ref PROFILES-CACHE-TABLE student-id #f)])
        (if (and (not force?) cached-entry stamp (equal? cache-key (car cached-entry)))
            (cdr cached-entry)
            (let* ([raw-data (with-handlers ([exn:fail?
                                              (lambda (e)
                                                (eprintf "[adaptativa] Aviso ao ler perfil ~a: ~a~n"
                                                         path (exn-message e))
                                                (default-profile student-id))])
                               (string->jsexpr (file->string path)))]
                   [data (clean-test-files-from-profile raw-data)])
              (hash-set! PROFILES-CACHE-TABLE student-id (cons cache-key data))
              data)))
      (default-profile student-id)))

(define (load-or-init-profile! student-id)
  (define path (get-profile-path student-id))
  (unless (file-exists? path)
    (save-profile! student-id (default-profile student-id))))

(define (save-profile! student-id data)
  (define path (get-profile-path student-id))
  (when (write-json-atomic! path data)
    (define cache-key (cons (path->string path) (file-stat-stamp path)))
    (hash-set! PROFILES-CACHE-TABLE student-id (cons cache-key data))))

(define (get-student-points student-id)
  (define profile (load-profile (or student-id (get-current-student))))
  (hash-ref profile 'total_sucessos 0))

(define (get-student-syntactic-level [student-id #f])
  (define id (or student-id (get-current-student)))
  (define config (load-teacher-config))
  (define forced-level (hash-ref config 'nivel_forcado #f))
  (if (and (number? forced-level) (member forced-level '(1 2 3)))
      forced-level
      (let ()
        (define points (get-student-points id))
        (define p2 (hash-ref config 'pontos_nivel_2 4))
        (define p3 (hash-ref config 'pontos_nivel_3 8))
        (cond
          [(>= points p3) 3]
          [(>= points p2) 2]
          [else 1]))))

(define (get-student-level student-id category)
  (define profile (load-profile (or student-id (get-current-student))))
  (define error-table (hash-ref profile 'erros (hasheq)))
  (define count (hash-ref error-table category 0))
  (cond
    [(<= count 1) 1]
    [(= count 2) 2]
    [else 3]))

(define (record-student-error! student-id category)
  (define id (or student-id (get-current-student)))
  (define profile (load-profile id))
  (define error-table (hash-ref profile 'erros (hasheq)))
  (define cat-sym (if (symbol? category) category (string->symbol (format "~a" category))))
  (define current-count (hash-ref error-table cat-sym 0))
  (define new-count (+ current-count 1))
  (define new-table (hash-set error-table cat-sym new-count))
  (define new-profile
    (hash-set (hash-set profile 'erros new-table)
              'total_erros (+ (hash-ref profile 'total_erros 0) 1)))
  (save-profile! id new-profile)
  (define level (get-student-level id cat-sym))
  (log-event! id 'erro cat-sym level "Ocorrência de erro pedagógico")
  level)

(define (record-student-success! student-id concept)
  (add-student-points! student-id 1 (or concept 'geral) "Instrução bem-sucedida"))

(define (add-student-points! student-id amount concept [details "Pontuação automática"])
  (define id (or student-id (get-current-student)))
  (define profile (load-profile id))
  (define new-bonus (+ (hash-ref profile 'bonus_pontos 0) amount))
  (define-values (cat-points _cats)
    (recalculate-points-by-categories (hash-ref profile 'arquivos (hasheq))))
  (define new-total (+ cat-points new-bonus))
  (define new-profile
    (hash-set (hash-set profile 'bonus_pontos new-bonus)
              'total_sucessos new-total))
  (save-profile! id new-profile)
  (log-event! id 'sucesso (or concept 'geral) 1 (format "~a (+~a pontos)" details amount))
  new-total)

(define (list-all-students)
  (define dir (get-data-dir-path))
  (define files (if (directory-exists? dir) (directory-list dir) '()))
  (define profile-students
    (filter-map
     (lambda (p)
       (define name (path->string p))
       (define m (regexp-match #px"^(.+)-perfil\\.json$" name))
       (and m
            (with-handlers ([exn:fail? (lambda (e) (cadr m))])
              (define j (string->jsexpr (file->string (build-path dir p))))
              (hash-ref j 'aluno (cadr m)))))
     files))
  (define current (get-current-student))
  (define all (remove-duplicates (cons current profile-students)))
  (sort (filter non-empty-string? all) string<?))

(define (register-new-student! name-or-id)
  (define clean-id (string-trim (if (string? name-or-id) name-or-id (format "~a" name-or-id))))
  (when (non-empty-string? clean-id)
    (set-current-student! clean-id)
    (save-profile! clean-id (default-profile clean-id))
    (log-event! clean-id 'sessao 'cadastro 0 "Novo aprendiz cadastrado pelo mediador"))
  clean-id)

(define (reset-student-progress! [student-id #f])
  (define id (or student-id (get-current-student)))
  (save-profile! id (default-profile id))
  (clear-profile-cache! id)
  (log-event! id 'sessao 'reinicio 0 "Progresso do aluno reiniciado pelo mediador")
  id)

(define (remove-student! student-id)
  (define id (if (string? student-id) student-id (format "~a" student-id)))
  (define path (get-profile-path id))
  (with-handlers ([exn:fail? (lambda (e) (void))])
    (when (file-exists? path)
      (delete-file path)))
  (clear-profile-cache! id)
  (when (equal? id (get-current-student))
    (define others (filter (lambda (a) (not (equal? a id))) (list-all-students)))
    (define next (if (pair? others) (car others) "aluno-anonimo"))
    (set-current-student! next))
  #t)
