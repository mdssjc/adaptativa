#lang racket/base

(require (except-in lang/htdp-beginner
                    #%module-begin
                    define
                    define-struct
                    cond
                    else
                    if
                    check-expect
                    check-error
                    check-within
                    e
                    and
                    or
                    not
                    sqr
                    expt
                    quotient)
         "pedagogy/auto-scoring.rkt"
         "pedagogy/feedback.rkt"
         "lib/primitives.rkt"
         "lib/visual.rkt"
         "lib/turtle.rkt")

(install-pedagogic-error-handler!)

(provide (all-from-out lang/htdp-beginner)
         (all-from-out "pedagogy/auto-scoring.rkt")
         (all-from-out "lib/primitives.rkt")
         (all-from-out "lib/visual.rkt")
         (all-from-out "lib/turtle.rkt"))
