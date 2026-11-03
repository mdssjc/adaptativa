#lang racket/base
(require rackunit
         racket/file
         "../tracker/logger.rkt"
         "../tracker/state.rkt"
         "../tracker/config.rkt"
         "../pedagogy/auto-scoring.rkt"
         "../pedagogy/teacher-report.rkt")

(define tmp-dir (make-temporary-file "adaptativa-score-test-~a" 'directory))
(dynamic-wind
  (lambda () (void))
  (lambda ()
    (parameterize ([current-data-dir tmp-dir])
      (clear-profile-cache!)
      (clear-config-cache!)
      (clear-events-cache!)
      (test-case "Verificação de contagem de pontos única por categoria e redução ao remover construtor"
        (define test-student "aluno_teste_categorias")
        (set-current-student! test-student)
        (save-profile! test-student (hasheq 'aluno test-student
                                            'erros (hasheq)
                                            'total_sucessos 0
                                            'bonus_pontos 0
                                            'total_erros 0
                                            'arquivos (hasheq)))
        (check-equal? (get-student-points test-student) 0)

        (compute-execution-points! #t #t #f #t "H:/exercicios/t1.rkt")
        (check-equal? (get-student-points test-student) 6)

        (compute-execution-points! #t #f #f #f "H:/exercicios/r33.rkt")
        (check-equal? (get-student-points test-student) 6)

        (define files (get-student-files test-student))
        (check-equal? (hash-count files) 2)

        (compute-execution-points! #t #f #t #f "H:/exercicios/r33.rkt")
        (check-equal? (get-student-points test-student) 9)

        (compute-execution-points! #f #f #f #f "H:/exercicios/verificacao.rkt")
        (check-equal? (get-student-points test-student) 9)

        (define report (generate-teacher-summary-text test-student))
        (check-true (regexp-match? #rx"Variáveis e Constantes" report))
        (check-true (regexp-match? #rx"Declaração de Funções" report))
        (check-true (regexp-match? #rx"Repetição e Iteração" report))
        (check-true (regexp-match? #rx"Desvio Condicional" report))
        (check-true (regexp-match? #rx"t1\\.rkt" report))
        (check-true (regexp-match? #rx"r33\\.rkt" report))

        (compute-execution-points! #t #f #f #t "H:/exercicios/t1.rkt")
        (check-equal? (get-student-points test-student) 7 "Pontuação deve diminuir para 7 ao remover a função")

        (define cats (get-student-categories test-student))
        (check-false (hash-ref cats 'funcao) "Categoria 'função' não deve mais constar como conquistada")
        (check-true (hash-ref cats 'variavel))
        (check-true (hash-ref cats 'condicional))
        (check-true (hash-ref cats 'repeticao)))))
  (lambda ()
    (clear-profile-cache!)
    (clear-config-cache!)
    (clear-events-cache!)
    (with-handlers ([exn:fail? void])
      (delete-directory/files tmp-dir))))
