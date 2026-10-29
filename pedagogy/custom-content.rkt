#lang racket/base

(require racket/file
         racket/path
         racket/string
         racket/list
         "../tracker/logger.rkt")

(provide get-default-lessons-dir
         get-custom-lessons-dir
         get-default-examples-dir
         get-custom-examples-dir
         list-custom-lessons
         list-custom-examples
         add-custom-lesson!
         remove-custom-lesson!
         add-custom-example!
         remove-custom-example!
         custom-lesson?
         custom-example?)

(define (get-default-lessons-dir)
  (with-handlers ([exn:fail? (lambda (e) (current-directory))])
    (define c-path (collection-file-path "info.rkt" "adaptativa"))
    (define-values (base name dir?) (split-path c-path))
    (simplify-path (build-path base "lessons"))))

(define (get-default-examples-dir)
  (with-handlers ([exn:fail? (lambda (e) (current-directory))])
    (define c-path (collection-file-path "info.rkt" "adaptativa"))
    (define-values (base name dir?) (split-path c-path))
    (simplify-path (build-path base "examples"))))

(define (get-custom-lessons-dir)
  (define base (get-data-dir-path))
  (define dir (build-path base "lessons"))
  (unless (directory-exists? dir)
    (make-directory* dir))
  dir)

(define (get-custom-examples-dir)
  (define base (get-data-dir-path))
  (define dir (build-path base "examples"))
  (unless (directory-exists? dir)
    (make-directory* dir))
  dir)

(define (list-custom-lessons)
  (define dir (get-custom-lessons-dir))
  (if (not (directory-exists? dir))
      '()
      (let* ([items (directory-list dir)]
             [files (filter (lambda (p)
                              (and (or (path-has-extension? p #".md")
                                       (path-has-extension? p #".txt")
                                       (path-has-extension? p #".rkt"))
                                   (file-exists? (build-path dir p))))
                            items)])
        (sort (map path->string files) string<?))))

(define (list-custom-examples)
  (define dir (get-custom-examples-dir))
  (if (not (directory-exists? dir))
      '()
      (let* ([items (directory-list dir)]
             [files (filter (lambda (p)
                              (and (path-has-extension? p #".rkt")
                                   (file-exists? (build-path dir p))))
                            items)])
        (sort (map path->string files) string<?))))

(define (custom-lesson? filename)
  (define path (build-path (get-custom-lessons-dir) filename))
  (file-exists? path))

(define (custom-example? filename)
  (define path (build-path (get-custom-examples-dir) filename))
  (file-exists? path))

(define (add-custom-lesson! src-path [dest-name #f])
  (unless (file-exists? src-path)
    (error 'add-custom-lesson! "Arquivo de origem não encontrado: ~a" src-path))
  (define name
    (or dest-name
        (let-values ([(b n d?) (split-path src-path)])
          (path->string n))))
  (define dest (build-path (get-custom-lessons-dir) name))
  (copy-file src-path dest #t)
  dest)

(define (remove-custom-lesson! filename)
  (define path (build-path (get-custom-lessons-dir) filename))
  (if (file-exists? path)
      (begin
        (delete-file path)
        #t)
      #f))

(define (add-custom-example! src-path [dest-name #f])
  (unless (file-exists? src-path)
    (error 'add-custom-example! "Arquivo de origem não encontrado: ~a" src-path))
  (define name
    (or dest-name
        (let-values ([(b n d?) (split-path src-path)])
          (path->string n))))
  (define dest (build-path (get-custom-examples-dir) name))
  (copy-file src-path dest #t)
  dest)

(define (remove-custom-example! filename)
  (define path (build-path (get-custom-examples-dir) filename))
  (if (file-exists? path)
      (begin
        (delete-file path)
        #t)
      #f))
