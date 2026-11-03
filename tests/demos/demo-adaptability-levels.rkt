#lang racket/base

(require "../../tracker/state.rkt"
         "../../pedagogy/feedback.rkt")

(define orig-student (get-current-student))
(define demo-student "demo_aluno_adaptativo")

(dynamic-wind
  (lambda () (void))
  (lambda ()
    (printf "===================================================================~n")
    (printf " DEMONSTRAÇÃO PRÁTICA: ESCALONAMENTO DOS 3 NÍVEIS DE ADAPTATIVIDADE~n")
    (printf " Linguagem Adaptativa (#lang adaptativa) - Casa do Idoso Sul / UNINTER~n")
    (printf "===================================================================~n~n")

    (set-current-student! demo-student)
    (reset-student-progress! demo-student)

    (define category 'definicao-vazia)
    (define contextual-hint "Você declarou o nome da variável ou função, mas esqueceu de fornecer o valor ou corpo.")

    (printf "Cenário didático:~n")
    (printf "O estudante idoso tentou escrever no DrRacket:~n")
    (printf "  (definir area-circulo)  <-- Faltou o valor ou cálculo!~n~n")

    (printf "-------------------------------------------------------------------~n")
    (printf "[1ª OCORRÊNCIA DO ERRO] -> Nível 1: Abordagem Socrática~n")
    (printf "(Estimula o raciocínio e autonomia, sem entregar a resposta pronta)~n")
    (printf "-------------------------------------------------------------------~n")

    (define level-1 (record-student-error! (get-current-student) category))
    (define msg-1 (generate-didactic-message category level-1 contextual-hint))

    (displayln msg-1)
    (printf "~n")

    (printf "-------------------------------------------------------------------~n")
    (printf "[2ª OCORRÊNCIA DO ERRO] -> Nível 2: Lembrete com Exemplo Prático~n")
    (printf "(O aprendiz errou novamente; fornecemos um modelo concreto de código)~n")
    (printf "-------------------------------------------------------------------~n")

    (define level-2 (record-student-error! (get-current-student) category))
    (define msg-2 (generate-didactic-message category level-2 contextual-hint))

    (displayln msg-2)
    (printf "~n")

    (printf "-------------------------------------------------------------------~n")
    (printf "[3ª OCORRÊNCIA DO ERRO] -> Nível 3: Guia Estruturado HtDP~n")
    (printf "(Dificuldade persistente; apresentamos o passo a passo da receita de design)~n")
    (printf "-------------------------------------------------------------------~n")

    (define level-3 (record-student-error! (get-current-student) category))
    (define msg-3 (generate-didactic-message category level-3 contextual-hint))

    (displayln msg-3)

    (printf "===================================================================~n")
    (printf "Demonstração finalizada. As métricas foram salvas em disco no perfil do aluno.~n")
    (printf "===================================================================~n"))
  (lambda ()
    (set-current-student! orig-student)
    (remove-student! demo-student)
    (clear-profile-cache!)))
