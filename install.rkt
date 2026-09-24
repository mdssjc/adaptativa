#lang racket/base

(require racket/system)

(define (run-cmd cmd . args)
  (define full-command (apply string-append cmd (map (lambda (a) (string-append " " a)) args)))
  (printf "> ~a~n" full-command)
  (system full-command))

(define executar run-cmd)

(printf "Configurando pacote adaptativa em modo link para Racket 9.3+...~n")
(unless (run-cmd "raco" "pkg" "install" "--link" "--name" "adaptativa")
  (printf "Atualizando vinculo do pacote adaptativa...~n")
  (run-cmd "raco" "pkg" "update" "--link" "--name" "adaptativa"))

(printf "Compilando metadados e colecoes...~n")
(run-cmd "raco" "setup" "--pkgs" "adaptativa")

(printf "Concluido! Colecao adaptativa pronta para uso no DrRacket.~n")
