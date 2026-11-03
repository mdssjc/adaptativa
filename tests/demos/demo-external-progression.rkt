#lang racket/base

(require "../../tracker/state.rkt"
         "../../tracker/config.rkt")

(define orig-cfg (load-teacher-config))
(define orig-student (get-current-student))
(define demo-student "demo_dona_benta")

(dynamic-wind
  (lambda () (void))
  (lambda ()
    (printf "===================================================================~n")
    (printf " DEMO: CONTROLE EXTERNO DE ALUNO E PROGRESSÃO SINTÁTICA EM 3 NÍVEIS~n")
    (printf " (Sem nenhuma necessidade de declarar aluno ou nível no código fonte!)~n")
    (printf "===================================================================~n~n")

    (printf "1. Professor seleciona o aluno da estação via GUI: '~a'~n" demo-student)
    (set-current-student! demo-student)
    (reset-student-progress! demo-student)
    (printf "   Aluno ativo no sistema: ~a~n" (get-current-student))
    (printf "   Pontuação inicial: ~a sucessos~n~n" (get-student-points demo-student))

    (printf "2. Verificando Nível Sintático Inicial:~n")
    (printf "   Nível atual: ~a (1 = Apenas Português | 2 = Bilíngue | 3 = HtDP Oficial)~n~n"
            (get-student-syntactic-level demo-student))

    (printf "3. ~a resolve exercícios e acumula 6 sucessos no sistema...~n" demo-student)
    (for ([i (in-range 6)])
      (record-student-success! demo-student 'exercicio))

    (printf "   Nova pontuação: ~a sucessos!~n" (get-student-points demo-student))
    (printf "   Novo Nível Sintático automático: ~a (Transição Bilíngue desbloqueada!)~n~n"
            (get-student-syntactic-level demo-student))

    (printf "4. Professor abre a janela de regras e define:~n")
    (printf "   - Pontos para Nível 2: 15 pontos~n")
    (printf "   - Pontos para Nível 3: 30 pontos~n")
    (save-teacher-config! (hash-set (hash-set (hash-set orig-cfg
                                                         'pontos_nivel_2 15)
                                              'pontos_nivel_3 30)
                                    'nivel_forcado #f))

    (printf "   Com a nova meta de 15 pontos, com 6 pontos ~a volta temporariamente ao Nível: ~a~n~n"
            demo-student (get-student-syntactic-level demo-student))

    (printf "5. Professor decide travar o modo da aula no 'Nível 3 (HtDP Oficial)':~n")
    (save-teacher-config! (hash-set (hash-set (hash-set orig-cfg
                                                         'pontos_nivel_2 15)
                                              'pontos_nivel_3 30)
                                    'nivel_forcado 3))

    (printf "   Nível ativo para qualquer aluno: ~a (HtDP Oficial forçado pelo mediador)~n~n"
            (get-student-syntactic-level demo-student))

    (printf "===================================================================~n")
    (printf "Demonstração concluída com sucesso!~n")
    (printf "===================================================================~n"))
  (lambda ()
    (save-teacher-config! orig-cfg)
    (set-current-student! orig-student)
    (remove-student! demo-student)
    (clear-profile-cache!)))
