#lang racket/base

(require rackunit
         racket/file
         racket/path
         "../pedagogy/hints-gui.rkt")

(printf "Iniciando testes de exemplos com metadados dinâmicos...\n")

(define examples (load-available-examples))
(check-true (>= (length examples) 6) "Deve haver pelo menos 6 exemplos carregados")

(define ex1 (car examples))
(check-equal? (hash-ref ex1 'nivel) 1 "Primeiro exemplo deve ser do nível 1")
(check-equal? (hash-ref ex1 'licao) 1 "Primeiro exemplo deve ser a lição 1")
(check-true (string? (hash-ref ex1 'label)) "Label deve ser uma string")

(check-equal? (get-suggested-index 1 examples) 0 "Nível 1 deve sugerir o primeiro exemplo")
(define idx-n2 (get-suggested-index 2 examples))
(check-true (>= idx-n2 2) "Nível 2 deve apontar para o primeiro exemplo de nível 2")
(check-equal? (hash-ref (list-ref examples idx-n2) 'nivel) 2)

(define idx-n3 (get-suggested-index 3 examples))
(check-true (> idx-n3 idx-n2) "Nível 3 deve estar após o nível 2")
(check-equal? (hash-ref (list-ref examples idx-n3) 'nivel) 3)

(define examples-dir
  (let ()
    (define c-path (collection-file-path "info.rkt" "adaptativa"))
    (define-values (base name dir?) (split-path c-path))
    (simplify-path (build-path base "examples"))))

(define new-example-path (build-path examples-dir "99-teste-instrutor.rkt"))

(dynamic-wind
  (lambda ()
    (display-to-file
     (string-append
      "#lang adaptativa\n\n"
      ";;; Metadados do Exemplo:\n"
      ";; @nivel: 2\n"
      ";; @licao: 99\n"
      ";; @titulo: Desafio Especial do Instrutor\n\n"
      "(mostrar \"Olá do novo exemplo!\")\n")
     new-example-path
     #:exists 'replace))
  (lambda ()
    (define new-examples (load-available-examples))
    (check-equal? (length new-examples) (+ (length examples) 1))

    (define found
      (for/first ([ex new-examples]
                  #:when (equal? (hash-ref ex 'arquivo) "99-teste-instrutor.rkt"))
        ex))

    (check-not-false found "O novo exemplo do instrutor deve ser encontrado")
    (check-equal? (hash-ref found 'nivel) 2)
    (check-equal? (hash-ref found 'licao) 99)
    (check-equal? (hash-ref found 'titulo) "Desafio Especial do Instrutor")
    (check-regexp-match #rx"🌿 \\[Nível 2\\] Lição 99: Desafio Especial do Instrutor"
                        (hash-ref found 'label))
    (printf "Novo exemplo do instrutor detectado e integrado com sucesso: ~a\n"
            (hash-ref found 'label)))
  (lambda ()
    (when (file-exists? new-example-path)
      (delete-file new-example-path))))

(printf "Todos os testes de metadados dinâmicos passaram com sucesso!\n")
