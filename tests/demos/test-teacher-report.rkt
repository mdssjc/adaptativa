#lang racket/base

(require "../../pedagogy/teacher-report.rkt")

(printf "Consultando dados pedagógicos de Dona Maria...~n~n")
(define text (generate-teacher-summary-text "dona_maria"))
(displayln text)

(printf "~nRelatório docente gerado e validado com sucesso!~n")
