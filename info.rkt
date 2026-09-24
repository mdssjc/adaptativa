#lang info

(define collection "adaptativa")
(define deps '("base" "htdp-lib" "gui-lib" "drracket-plugin-lib"))
(define build-deps '("rackunit-lib" "scribble-lib" "racket-doc"))
(define pkg-desc "Linguagem Educacional Adaptativa em Português (#lang adaptativa) para DrRacket")
(define version "1.0")
(define pkg-authors '("Marcelo dos Santos"))
(define compile-omit-paths '("examples" "tests"))
(define test-omit-paths '("tests/fixtures" "tests/demos"))

(define drracket-tools '(("tool.rkt")))
(define drracket-tool-names '("Linguagem Adaptativa"))
(define drracket-tool-icons '(#f))

(define scribblings '(("doc/adaptativa.scrbl" () (teaching))))
