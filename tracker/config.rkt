#lang racket/base

(require racket/file
         racket/string
         file/sha1
         json
         "logger.rkt")

(provide load-teacher-config
         save-teacher-config!
         clear-config-cache!
         get-teacher-config-path
         get-teacher-pin
         teacher-pin-registered?
         save-teacher-pin!
         verify-teacher-pin
         reset-teacher-pin!)

(define (get-teacher-config-path)
  (build-path (get-data-dir-path) "config-docente.json"))

(define (default-config)
  (hasheq 'pontos_nivel_2 4
          'pontos_nivel_3 8
          'nivel_forcado #f
          'pin_docente #f
          'pts_variavel 1
          'pts_funcao 2
          'pts_condicional 3
          'pts_repeticao 3
          'pts_teste 2))

(define CONFIG-CACHE #f)
(define CONFIG-CACHE-KEY #f)

(define (clear-config-cache!)
  (set! CONFIG-CACHE #f)
  (set! CONFIG-CACHE-KEY #f))

(define (load-teacher-config)
  (define path (get-teacher-config-path))
  (if (file-exists? path)
      (let* ([stamp (file-stat-stamp path)]
             [cache-key (cons (path->string path) stamp)])
        (if (and CONFIG-CACHE stamp (equal? cache-key CONFIG-CACHE-KEY))
            CONFIG-CACHE
            (let ([cfg (with-handlers ([exn:fail?
                                        (lambda (e)
                                          (eprintf "[adaptativa] Aviso: config-docente.json corrompido (~a); usando padrão.~n"
                                                   (exn-message e))
                                          (default-config))])
                         (string->jsexpr (file->string path)))])
              (set! CONFIG-CACHE cfg)
              (set! CONFIG-CACHE-KEY cache-key)
              cfg)))
      (let ([default-cfg (default-config)])
        (save-teacher-config! default-cfg)
        default-cfg)))

(define (save-teacher-config! cfg)
  (set! CONFIG-CACHE cfg)
  (define path (get-teacher-config-path))
  (when (write-json-atomic! path cfg)
    (set! CONFIG-CACHE-KEY (cons (path->string path) (file-stat-stamp path)))))

(define (hash-pin pin-str)
  (define clean (string-trim pin-str))
  (string-append "sha256:" (bytes->hex-string (sha256-bytes (open-input-string clean)))))

(define (get-teacher-pin)
  (define cfg (load-teacher-config))
  (hash-ref cfg 'pin_docente #f))

(define (teacher-pin-registered?)
  (define pin (get-teacher-pin))
  (and (string? pin) (non-empty-string? (string-trim pin))))

(define (save-teacher-pin! pin-str)
  (define clean-pin (if (string? pin-str) (string-trim pin-str) (format "~a" pin-str)))
  (define hashed (hash-pin clean-pin))
  (define cfg (load-teacher-config))
  (define new-cfg (hash-set cfg 'pin_docente hashed))
  (save-teacher-config! new-cfg)
  hashed)

(define (verify-teacher-pin pin-str)
  (define saved-pin (get-teacher-pin))
  (and (string? saved-pin)
       (string? pin-str)
       (let ([trimmed (string-trim pin-str)])
         (if (string-prefix? saved-pin "sha256:")
             (string=? (hash-pin trimmed) saved-pin)
             (string=? trimmed (string-trim saved-pin))))))

(define (reset-teacher-pin!)
  (define cfg (load-teacher-config))
  (define new-cfg (hash-set cfg 'pin_docente #f))
  (save-teacher-config! new-cfg)
  #t)
