#lang racket/base

(require (prefix-in 2img: 2htdp/image)
         (prefix-in 2uni: 2htdp/universe)
         (only-in lang/prim define-higher-order-primitive))

(provide
 desenhar-circulo
 desenhar-quadrado
 desenhar-retangulo
 desenhar-triangulo
 desenhar-estrela
 desenhar-texto
 desenhar-cenario
 colocar-figura
 largura-figura
 altura-figura
 figura?
 sobrepor
 lado-a-lado
 acima-de
 rotacionar
 espelhar-horizontal
 espelhar-vertical
 criar-animacao
 translate-mode
 translate-color)

(define (translate-mode mode)
  (cond
    [(or (equal? mode "solido") (equal? mode 'solido)) "solid"]
    [(or (equal? mode "contorno") (equal? mode 'contorno)) "outline"]
    [else mode]))

(define (translate-color color)
  (cond
    [(or (equal? color "vermelho") (equal? color 'vermelho)) "red"]
    [(or (equal? color "azul") (equal? color 'azul)) "blue"]
    [(or (equal? color "verde") (equal? color 'verde)) "green"]
    [(or (equal? color "amarelo") (equal? color 'amarelo)) "yellow"]
    [(or (equal? color "preto") (equal? color 'preto)) "black"]
    [(or (equal? color "branco") (equal? color 'branco)) "white"]
    [(or (equal? color "laranja") (equal? color 'laranja)) "orange"]
    [(or (equal? color "roxo") (equal? color 'roxo)) "purple"]
    [(or (equal? color "cinza") (equal? color 'cinza)) "gray"]
    [(or (equal? color "marrom") (equal? color 'marrom)) "brown"]
    [(or (equal? color "rosa") (equal? color 'rosa)) "pink"]
    [(or (equal? color "azul-ceu") (equal? color 'azul-ceu)) "light blue"]
    [(or (equal? color "verde-escuro") (equal? color 'verde-escuro)) "dark green"]
    [(or (equal? color "cinza-claro") (equal? color 'cinza-claro)) "light gray"]
    [(or (equal? color "dourado") (equal? color 'dourado)) "gold"]
    [(or (equal? color "prata") (equal? color 'prata)) "silver"]
    [else color]))

(define (desenhar-circulo radius [mode "solido"] [color "azul"])
  (2img:circle radius (translate-mode mode) (translate-color color)))

(define (desenhar-quadrado side [mode "solido"] [color "vermelho"])
  (2img:square side (translate-mode mode) (translate-color color)))

(define (desenhar-retangulo width height [mode "solido"] [color "verde"])
  (2img:rectangle width height (translate-mode mode) (translate-color color)))

(define (desenhar-triangulo side [mode "solido"] [color "laranja"])
  (2img:triangle side (translate-mode mode) (translate-color color)))

(define (desenhar-estrela radius [mode "solido"] [color "amarelo"])
  (2img:star radius (translate-mode mode) (translate-color color)))

(define (desenhar-texto content [size 20] [color "preto"])
  (2img:text (format "~a" content) size (translate-color color)))

(define (desenhar-cenario width height [color "branco"])
  (2img:empty-scene width height (translate-color color)))

(define (colocar-figura figure x y scene)
  (2img:place-image figure x y scene))

(define (largura-figura img)
  (2img:image-width img))

(define (altura-figura img)
  (2img:image-height img))

(define (figura? val)
  (2img:image? val))

(define (sobrepor img1 img2 . rest)
  (apply 2img:overlay img1 img2 rest))

(define (lado-a-lado img1 img2 . rest)
  (apply 2img:beside img1 img2 rest))

(define (acima-de img1 img2 . rest)
  (apply 2img:above img1 img2 rest))

(define (rotacionar angle img)
  (2img:rotate angle img))

(define (espelhar-horizontal img)
  (2img:flip-horizontal img))

(define (espelhar-vertical img)
  (2img:flip-vertical img))

(define (criar-animacao-impl frame-func)
  (2uni:animate frame-func))

(define-higher-order-primitive criar-animacao criar-animacao-impl (frame-func))
