#lang racket/base

(require racket/gui/base
         racket/class
         racket/math
         "visual.rkt")

(provide
 iniciar-tartaruga
 tartaruga
 abrir-tartaruga
 fechar-tartaruga
 avancar
 recuar
 girar-direita
 girar-esquerda
 ir-para
 definir-angulo
 levantar-caneta
 abaixar-caneta
 caneta-abaixada?
 mudar-cor
 cor-caneta
 mudar-espessura
 espessura-caneta
 limpar-tela
 voltar-ao-centro
 esconder-tartaruga
 mostrar-tartaruga
 tartaruga-visivel?
 velocidade-tartaruga
 obter-x
 posicao-x
 obter-y
 posicao-y
 obter-angulo
 salvar-desenho)

(define DEFAULT-WIDTH 600)
(define DEFAULT-HEIGHT 600)

(define turtle-window #f)
(define turtle-canvas #f)
(define memory-bitmap #f)
(define memory-dc #f)

(define pos-x 0.0)
(define pos-y 0.0)
(define current-angle 90)

(define pen-active? #t)
(define current-color "preto")
(define current-width 2)
(define turtle-visible? #t)
(define turtle-speed 0)

(define (to-canvas-x x [w DEFAULT-WIDTH])
  (+ (/ w 2.0) x))

(define (to-canvas-y y [h DEFAULT-HEIGHT])
  (- (/ h 2.0) y))

(define (ensure-window! [width DEFAULT-WIDTH] [height DEFAULT-HEIGHT])
  (unless (and turtle-window (send turtle-window is-shown?))
    (set! DEFAULT-WIDTH width)
    (set! DEFAULT-HEIGHT height)
    
    (set! memory-bitmap (make-bitmap width height))
    (set! memory-dc (new bitmap-dc% [bitmap memory-bitmap]))
    (send memory-dc set-smoothing 'aligned)
    (send memory-dc set-background (make-color 255 255 255))
    (send memory-dc clear)

    (set! turtle-window
          (new frame%
               [label "🐢 Tartaruga Adaptativa (Casa do Idoso Sul)"]
               [width width]
               [height height]
               [style '(no-resize-border)]))

    (set! turtle-canvas
          (new (class canvas%
                 (inherit get-dc)
                 (define/override (on-paint)
                   (define dc (get-dc))
                   (send dc set-smoothing 'aligned)
                   (send dc draw-bitmap memory-bitmap 0 0)
                   (when turtle-visible?
                     (draw-turtle-icon dc)))
                 (super-new [parent turtle-window]))))

    (send turtle-window center 'both)
    (send turtle-window show #t)))

(define (draw-turtle-icon dc)
  (define cx (to-canvas-x pos-x DEFAULT-WIDTH))
  (define cy (to-canvas-y pos-y DEFAULT-HEIGHT))
  (define rad (degrees->radians current-angle))
  
  (define tip-size 16.0)
  (define wing-size 10.0)
  (define wing-angle (degrees->radians 145.0))

  (define beak-x (+ cx (* tip-size (cos rad))))
  (define beak-y (- cy (* tip-size (sin rad))))

  (define left-wing-x (+ cx (* wing-size (cos (+ rad wing-angle)))))
  (define left-wing-y (- cy (* wing-size (sin (+ rad wing-angle)))))

  (define right-wing-x (+ cx (* wing-size (cos (- rad wing-angle)))))
  (define right-wing-y (- cy (* wing-size (sin (- rad wing-angle)))))

  (define old-pen (send dc get-pen))
  (define old-brush (send dc get-brush))

  (send dc set-pen (send the-pen-list find-or-create-pen "darkgreen" 2 'solid))
  (send dc set-brush (send the-brush-list find-or-create-brush "lightgreen" 'solid))

  (define path (new dc-path%))
  (send path move-to beak-x beak-y)
  (send path line-to left-wing-x left-wing-y)
  (send path line-to cx cy)
  (send path line-to right-wing-x right-wing-y)
  (send path close)
  (send dc draw-path path)

  (send dc set-pen old-pen)
  (send dc set-brush old-brush))

(define (refresh-canvas!)
  (when (and turtle-canvas (send turtle-window is-shown?))
    (send turtle-canvas refresh-now)))

(define (iniciar-tartaruga [width DEFAULT-WIDTH] [height DEFAULT-HEIGHT])
  (ensure-window! width height)
  (limpar-tela)
  (voltar-ao-centro)
  (void))

(define (fechar-tartaruga)
  (when (and turtle-window (send turtle-window is-shown?))
    (send turtle-window show #f))
  (void))

(define (draw-segment! x1 y1 x2 y2)
  (when pen-active?
    (define cx1 (to-canvas-x x1 DEFAULT-WIDTH))
    (define cy1 (to-canvas-y y1 DEFAULT-HEIGHT))
    (define cx2 (to-canvas-x x2 DEFAULT-WIDTH))
    (define cy2 (to-canvas-y y2 DEFAULT-HEIGHT))
    (define pen-color (translate-color current-color))
    (send memory-dc set-pen (send the-pen-list find-or-create-pen pen-color current-width 'solid))
    (send memory-dc draw-line cx1 cy1 cx2 cy2)))

(define (move-to! target-x target-y)
  (ensure-window!)
  (define start-x pos-x)
  (define start-y pos-y)
  (define dx (- target-x start-x))
  (define dy (- target-y start-y))
  (define dist (sqrt (+ (* dx dx) (* dy dy))))
  (if (or (= turtle-speed 0) (< dist 1.0))
      (begin
        (draw-segment! start-x start-y target-x target-y)
        (set! pos-x (real->double-flonum target-x))
        (set! pos-y (real->double-flonum target-y))
        (refresh-canvas!))
      (let* ([step-px (+ 2.0 (* turtle-speed 1.5))]
             [steps (max 1 (inexact->exact (ceiling (/ dist step-px))))]
             [delay (/ (- 11 turtle-speed) 250.0)])
        (for ([i (in-range 1 (+ steps 1))])
          (define frac (if (= i steps) 1.0 (/ i steps)))
          (define next-x (real->double-flonum (+ start-x (* dx frac))))
          (define next-y (real->double-flonum (+ start-y (* dy frac))))
          (draw-segment! pos-x pos-y next-x next-y)
          (set! pos-x next-x)
          (set! pos-y next-y)
          (refresh-canvas!)
          (sleep/yield delay))))
  (void))

(define (avancar [distance 100])
  (define rad (degrees->radians current-angle))
  (define new-x (+ pos-x (* distance (cos rad))))
  (define new-y (+ pos-y (* distance (sin rad))))
  (move-to! new-x new-y))

(define (recuar [distance 100])
  (avancar (- distance)))

(define (pause-turn!)
  (when (> turtle-speed 0)
    (sleep/yield (/ (- 11 turtle-speed) 120.0))))

(define (girar-direita [degrees 90])
  (ensure-window!)
  (set! current-angle (modulo (round (- current-angle degrees)) 360))
  (refresh-canvas!)
  (pause-turn!)
  (void))

(define (girar-esquerda [degrees 90])
  (ensure-window!)
  (set! current-angle (modulo (round (+ current-angle degrees)) 360))
  (refresh-canvas!)
  (pause-turn!)
  (void))

(define (ir-para new-x new-y)
  (move-to! (real->double-flonum new-x) (real->double-flonum new-y)))

(define (definir-angulo new-angle)
  (ensure-window!)
  (set! current-angle (modulo (round new-angle) 360))
  (refresh-canvas!)
  (pause-turn!)
  (void))

(define (levantar-caneta)
  (set! pen-active? #f)
  (void))

(define (abaixar-caneta)
  (set! pen-active? #t)
  (void))

(define (caneta-abaixada?)
  pen-active?)

(define (mudar-cor new-color)
  (set! current-color (format "~a" new-color))
  (void))

(define (mudar-espessura new-width)
  (when (and (real? new-width) (> new-width 0))
    (set! current-width (round new-width)))
  (void))

(define (limpar-tela)
  (ensure-window!)
  (send memory-dc clear)
  (refresh-canvas!)
  (void))

(define (voltar-ao-centro)
  (ensure-window!)
  (set! pos-x 0.0)
  (set! pos-y 0.0)
  (set! current-angle 90)
  (refresh-canvas!)
  (void))

(define (esconder-tartaruga)
  (set! turtle-visible? #f)
  (refresh-canvas!)
  (void))

(define (mostrar-tartaruga)
  (set! turtle-visible? #t)
  (refresh-canvas!)
  (void))

(define (tartaruga-visivel?)
  turtle-visible?)

(define (velocidade-tartaruga [nivel 5])
  (when (real? nivel)
    (set! turtle-speed (max 0 (min 10 (inexact->exact (round nivel))))))
  (void))

(define (obter-x) pos-x)
(define (obter-y) pos-y)
(define (obter-angulo) current-angle)

(define (salvar-desenho file-path)
  (ensure-window!)
  (send memory-bitmap save-file file-path 'png)
  (void))

(define tartaruga iniciar-tartaruga)
(define turtle iniciar-tartaruga)
(define abrir-tartaruga iniciar-tartaruga)

(define frente avancar)
(define forward avancar)
(define fd avancar)

(define tras recuar)
(define backward recuar)
(define bk recuar)

(define direita girar-direita)
(define right girar-direita)
(define rt girar-direita)

(define esquerda girar-esquerda)
(define left girar-esquerda)
(define lt girar-esquerda)

(define posicao ir-para)
(define goto ir-para)
(define setpos ir-para)

(define setheading definir-angulo)

(define levantar levantar-caneta)
(define penup levantar-caneta)
(define pu levantar-caneta)

(define abaixar abaixar-caneta)
(define pendown abaixar-caneta)
(define pd abaixar-caneta)

(define isdown? caneta-abaixada?)

(define cor-caneta mudar-cor)
(define pencolor mudar-cor)

(define espessura-caneta mudar-espessura)
(define pensize mudar-espessura)

(define limpar limpar-tela)
(define clear limpar-tela)

(define centro voltar-ao-centro)
(define home voltar-ao-centro)

(define hideturtle esconder-tartaruga)
(define ht esconder-tartaruga)

(define showturtle mostrar-tartaruga)
(define st mostrar-tartaruga)

(define velocidade velocidade-tartaruga)
(define speed velocidade-tartaruga)

(define posicao-x obter-x)
(define xcor obter-x)

(define posicao-y obter-y)
(define ycor obter-y)

(define heading obter-angulo)
