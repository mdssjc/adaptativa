#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 3
;; @licao: 8
;; @titulo: Animações e Funções do Tempo ('criar-animacao' & 'rotacionar')

(mostrar "=== Nível 3 - Lição 8: Animações no Espaço Sideral ===")
(mostrar "Aqui combinamos translação e rotação em função do tempo 't'.")

;; 1. Cenário noturno e astros (usando 'define', 'quotient' e 'check-expect')
(define largura-ceu 420)
(define ceu-noturno (desenhar-cenario largura-ceu 240 "preto"))
(define lua (desenhar-circulo 24 "solido" "prata"))
(define cenario-com-lua (colocar-figura lua 355 55 ceu-noturno))

(define estrela-central (desenhar-estrela 38 "solido" "dourado"))
(define cometa (desenhar-circulo 10 "solido" "azul-ceu"))

;; 2. Função pura de quadro: gira a estrela no centro e move o cometa pelo céu
;; Usa 'if', 'and' e 'not' para alternar a velocidade do cometa na metade direita da tela
(define (posicao-x-cometa t)
  (resto-divisao (multiplicar t 6) largura-ceu))

(define (desenhar-quadro t)
  (colocar-figura
   (rotacionar (multiplicar t 4) estrela-central)
   (quotient largura-ceu 2)
   130
   (colocar-figura
    cometa
    (posicao-x-cometa t)
    (if (and (>= (posicao-x-cometa t) (quotient largura-ceu 2))
             (not (= t 0)))
        90
        (somar 35 (resto-divisao (multiplicar t 2) 150)))
    cenario-com-lua)))

;; 3. Validando que a função produz figuras válidas antes de animar
(check-expect (figura? (desenhar-quadro 0)) verdadeiro)
(check-expect (figura? (desenhar-quadro 30)) verdadeiro)

(mostrar "Abrindo animação espacial! Feche a janela quando quiser encerrar.")

;; 4. Inicia a animação contínua
(criar-animacao desenhar-quadro)
