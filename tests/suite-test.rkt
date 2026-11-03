#lang racket/base

(require rackunit
         rackunit/text-ui
         racket/port
         racket/file
         racket/runtime-path
         (except-in "../lib/primitives.rkt" define if cond check-expect and or not sqr expt quotient)
         "../lib/visual.rkt"
         "../lib/turtle.rkt"
         "../pedagogy/feedback.rkt"
         "../pedagogy/teacher-report.rkt"
         "../lang/pedagogic-reader.rkt"
         "../tracker/state.rkt"
         "../tracker/logger.rkt")

(provide adaptativa-suite
         suite-adaptativa)

(define-runtime-path fixture-error-def "fixtures/test-error-definition.rkt")
(define-runtime-path fixture-error-if "fixtures/test-error-if.rkt")

(define adaptativa-suite
  (test-suite
   "Complete Adaptativa Language Test Suite"

   (test-suite
    "Primitives and Predicates"
    (test-case "Relational operators"
      (check-true (igual? 10 10))
      (check-false (igual? 10 20))
      (check-true (diferente? 5 8))
      (check-true (maior? 15 10))
      (check-true (menor? 3 7))
      (check-true (maior-ou-igual? 20 20))
      (check-true (menor-ou-igual? 15 20)))

    (test-case "Numeric and arithmetic predicates"
      (check-true (e-par? 4))
      (check-false (e-par? 5))
      (check-true (e-impar? 7))
      (check-true (e-positivo? 10))
      (check-true (e-negativo? -3))
      (check-true (e-zero? 0))
      (check-equal? (raiz-quadrada 25) 5)
      (check-equal? (arredondar 4.6) 5.0)
      (check-equal? (resto-divisao 10 3) 1)
      (check-equal? (somar 10 20) 30)
      (check-equal? (subtrair 30 10) 20)
      (check-equal? (multiplicar 4 5) 20)
      (check-equal? (dividir 100 4) 25)
      (check-equal? (+ 10 20) 30)
      (check-equal? (- 30 10) 20)
      (check-equal? (* 4 5) 20)
      (check-equal? (/ 100 4) 25)
      (check-equal? (absoluto -15) 15)
      (check-equal? (maximo 10 50 30) 50)
      (check-equal? (minimo 10 50 5) 5)
      (check-equal? (quadrado 6) 36)
      (check-equal? (quociente 17 5) 3)
      (check-equal? (potencia 2 3) 8)
      (check-true verdadeiro)
      (check-false falso))

    (test-case "Terminal input primitives"
      (check-equal? (with-input-from-string "Entrada texto\n" (lambda () (ler-linha))) "Entrada texto")
      (check-equal? (with-input-from-string "Alias texto\n" (lambda () (ler-texto))) "Alias texto")
      (check-equal? (with-input-from-string "100\n" (lambda () (ler-numero))) 100)))

   (test-suite
    "Pedagogical Feedback Engine"
    (test-case "Level 1 Messages (Socratic)"
      (define msg (generate-didactic-message 'definicao-vazia 1 "Esqueceu o valor"))
      (check-true (string? msg))
      (check-regexp-match #rx"💡 Atenção" msg))

    (test-case "Level 2 Messages (Practical Example)"
      (define msg (generate-didactic-message 'definicao-vazia 2 "Esqueceu o valor"))
      (check-true (string? msg))
      (check-regexp-match #rx"📘 Lembrete Prático" msg)
      (check-regexp-match #rx"definir" msg))

    (test-case "Level 3 Messages (HtDP Design Recipe Guide)"
      (define msg (generate-didactic-message 'definicao-vazia 3 "Esqueceu o valor"))
      (check-true (string? msg))
      (check-regexp-match #rx"Guia HtDP" msg)
      (check-regexp-match #rx"Design Recipe" msg)))

   (test-suite
    "Tracker and Learner State"
    (test-case "Student identification, switching, and error progression"
      (define orig-student (get-current-student))
      (dynamic-wind
        (lambda () (void))
        (lambda ()
          (set-current-student! "aluno_teste_unidade")
          (check-equal? (get-current-student) "aluno_teste_unidade")

          (set-current-student! "aluno_teste_progresso")
          (reset-student-progress! "aluno_teste_progresso")
          (define level1 (record-student-error! "aluno_teste_progresso" 'teste-cat))
          (define level2 (record-student-error! "aluno_teste_progresso" 'teste-cat))
          (check-equal? level1 1)
          (check-equal? level2 2))
        (lambda ()
          (set-current-student! orig-student)
          (remove-student! "aluno_teste_unidade")
          (remove-student! "aluno_teste_progresso")
          (clear-profile-cache!)))))

   (test-suite
    "Visual Library"
    (test-case "Valid geometric shapes generation"
      (define c (desenhar-circulo 20 "solido" "azul"))
      (define q (desenhar-quadrado 30 "solido" "vermelho"))
      (define r (desenhar-retangulo 40 20 "solido" "verde"))
      (define t (desenhar-triangulo 30 "solido" "laranja"))
      (define e (desenhar-estrela 25 "solido" "amarelo"))
      (define txt (desenhar-texto "Oi" 18 "preto"))
      (check-not-false c)
      (check-not-false q)
      (check-not-false r)
      (check-not-false t)
      (check-not-false e)
      (check-not-false txt))

    (test-case "Spatial composition"
      (define c (desenhar-circulo 15 "solido" "azul"))
      (define q (desenhar-quadrado 20 "solido" "vermelho"))
      (define ov (sobrepor c q))
      (define beside (lado-a-lado c q))
      (define above (acima-de c q))
      (check-not-false ov)
      (check-not-false beside)
      (check-not-false above))

    (test-case "Visual scenes and coordinates"
      (define scn (desenhar-cenario 200 150 "azul-ceu"))
      (define circ (desenhar-circulo 20 "solido" "amarelo"))
      (define comp (colocar-figura circ 100 75 scn))
      (check-not-false scn)
      (check-not-false comp)
      (check-equal? (largura-figura circ) 40)
      (check-equal? (altura-figura circ) 40))

    (test-case "Animation primitive definition"
      (define (quadro-teste t) (desenhar-circulo 10 "solido" "vermelho"))
      (check-true (procedure? quadro-teste)))

    (test-case "Turtle graphics movement and pen controls"
      (define (xr v) (inexact->exact (round v)))
      (voltar-ao-centro)
      (check-equal? (xr (obter-x)) 0)
      (check-equal? (xr (obter-y)) 0)
      (check-equal? (xr (obter-angulo)) 90)
      (girar-direita 90)
      (check-equal? (xr (obter-angulo)) 0)
      (avancar 100)
      (check-equal? (xr (obter-x)) 100)
      (check-equal? (xr (obter-y)) 0)
      (girar-esquerda 90)
      (check-equal? (xr (obter-angulo)) 90)
      (avancar 50)
      (check-equal? (xr (obter-x)) 100)
      (check-equal? (xr (obter-y)) 50)
      (recuar 50)
      (check-equal? (xr (obter-y)) 0)
      (levantar-caneta)
      (check-false (caneta-abaixada?))
      (abaixar-caneta)
      (check-true (caneta-abaixada?))
      (mudar-cor "azul")
      (mudar-espessura 4)
      (fechar-tartaruga))

    (test-case "Text manipulation and conversions"
      (check-equal? (juntar-texto "Olá " "Mundo " 2026) "Olá Mundo 2026")
      (check-equal? (tamanho-texto "Racket") 6)
      (check-equal? (texto->numero "123") 123)
      (check-equal? (numero->texto 456) "456")
      (check-equal? (texto-maiusculo "adaptativa") "ADAPTATIVA")
      (check-equal? (texto-minusculo "ADAPTATIVA") "adaptativa"))

    (test-case "Lists and collections"
      (define lst (lista 10 20 30))
      (check-equal? (tamanho-lista lst) 3)
      (check-equal? (primeiro lst) 10)
      (check-equal? (resto lst) (list 20 30))
      (check-false (vazia? lst))
      (check-true (vazia? (lista)))
      (check-equal? (juntar-listas (lista 1 2) (lista 3 4)) (list 1 2 3 4))
      (check-equal? (inverter-lista (lista 1 2 3)) (list 3 2 1))))

   (test-suite
    "Pedagogic Reader"
    (test-case "Reader error translation for syntax mistakes"
      (check-regexp-match #rx"Texto não fechado" (translate-read-message "read-syntax: expected a closing `\"`"))
      (check-regexp-match #rx"Texto não fechado" (translate-read-message "test::1: read-syntax: expected a closing `\"`"))
      (check-regexp-match #rx"Caractere não fechado" (translate-read-message "read-syntax: expected a closing `'`"))
      (check-regexp-match #rx"Parêntese não fechado" (translate-read-message "read-syntax: expected a `)` to close `(`"))
      (check-regexp-match #rx"Colchete não fechado" (translate-read-message "read-syntax: expected a `]` to close `[`"))
      (check-regexp-match #rx"Chave não fechada" (translate-read-message "read-syntax: expected a `}` to close `{`"))
      (check-regexp-match #rx"Parêntese sobrando" (translate-read-message "read-syntax: unexpected `)`"))
      (check-regexp-match #rx"Colchete sobrando" (translate-read-message "read-syntax: unexpected `]`"))
      (check-regexp-match #rx"Chave sobrando" (translate-read-message "read-syntax: unexpected `}`"))
      (check-regexp-match #rx"Ponto final fora de lugar" (translate-read-message "read-syntax: illegal use of `.`"))
      (check-regexp-match #rx"Caractere especial desconhecido" (translate-read-message "read-syntax: bad syntax: #xyz"))
      (check-regexp-match #rx"Cabeçalho fora do início" (translate-read-message "#lang not at beginning of file"))))

   (test-suite
    "Runtime Pedagogic Errors"
    (test-case "Translation of common runtime errors"
      (check-regexp-match #rx"Nome desconhecido" (translate-runtime-message "saldo: this variable is not defined"))
      (check-regexp-match #rx"Nome desconhecido" (translate-runtime-message "total: undefined; cannot use before initialization"))
      (check-regexp-match #rx"Divisão por zero" (translate-runtime-message "/: division by zero"))
      (check-regexp-match #rx"Quantidade incorreta" (translate-runtime-message "quadrado: arity mismatch;\n expected: 1\n given: 3"))
      (check-regexp-match #rx"Quantidade incorreta" (translate-runtime-message "somar: expects 2 arguments, given 1"))
      (check-regexp-match #rx"calcular com texto" (translate-runtime-message "+: contract violation; expected: number?, given: \"vinte\""))
      (check-regexp-match #rx"Esperava um texto" (translate-runtime-message "string-length: contract violation; given: 123"))
      (check-regexp-match #rx"Esperava uma lista" (translate-runtime-message "first: contract violation; expected: pair?, given: 99"))
      (check-regexp-match #rx"Lista vazia" (translate-runtime-message "first: expects argument of type <non-empty list>; given: '()"))
      (check-regexp-match #rx"Raiz quadrada inválida" (translate-runtime-message "sqrt: contract violation; expected: (and/c number? (not/c negative?)), given: -9"))
      (check-regexp-match #rx"Nenhuma opção foi atendida" (translate-runtime-message "cond: all question results were false"))
      (check-regexp-match #rx"Palavra reservada" (translate-runtime-message "se: this name was defined in the language or a required library and cannot be re-defined"))
      (check-regexp-match #rx"Nome já definido" (translate-runtime-message "idade: this name was defined previously and cannot be re-defined"))))

   (test-suite
    "Teacher Report"
    (test-case "Tracking text generation"
      (define txt (generate-teacher-summary-text "aluno_teste_progresso"))
      (check-true (string? txt))
      (check-regexp-match #rx"CASA DO IDOSO SUL" txt)
      (check-regexp-match #rx"aluno_teste_progresso" txt)))

   (test-suite
    "Security and Error Fixtures"
    (test-case "Sanitization of student filenames"
      (check-equal? (sanitize-student-filename "Maria/João: Turma*1?") "Maria_João_ Turma_1_")
      (check-equal? (sanitize-student-filename "../../etc/passwd") "____etc_passwd")
      (check-equal? (sanitize-student-filename "   ") "aluno-anonimo"))

    (test-case "Error fixtures raise expected pedagogic syntax errors"
      (define (eval-adaptativa-file p)
        (parameterize ([current-namespace (make-base-namespace)])
          (dynamic-require p #f)))
      (check-exn exn:fail:syntax?
                 (lambda () (eval-adaptativa-file fixture-error-def)))
      (check-exn exn:fail:syntax?
                 (lambda () (eval-adaptativa-file fixture-error-if)))))))

(define suite-adaptativa adaptativa-suite)

(define (run-isolated-suite)
  (define tmp-dir (make-temporary-file "adaptativa-test-~a" 'directory))
  (dynamic-wind
    (lambda () (void))
    (lambda ()
      (parameterize ([current-data-dir tmp-dir])
        (clear-profile-cache!)
        (run-tests adaptativa-suite)))
    (lambda ()
      (clear-profile-cache!)
      (with-handlers ([exn:fail? void])
        (delete-directory/files tmp-dir)))))

(module+ test
  (unless (zero? (run-isolated-suite))
    (error 'suite-test "Alguns testes falharam")))

(module+ main
  (printf "Executando bateria de testes do #lang adaptativa...~n~n")
  (run-isolated-suite))
