#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 3
;; @licao: 8
;; @titulo: Animações e Funções do Tempo ('criar-animacao' & 'rotacionar')

(mostrar "=== Nível 3 - Lição 8: Animações no Espaço Sideral ===")
(mostrar "Aqui combinamos translação e rotação em função do tempo 't'.")

;; 1. Cenário noturno e astros
(definir ceu-noturno (desenhar-cenario 420 240 "preto"))
(definir lua (desenhar-circulo 24 "solido" "prata"))
(definir cenario-com-lua (colocar-figura lua 355 55 ceu-noturno))

(definir estrela-central (desenhar-estrela 38 "solido" "dourado"))
(definir cometa (desenhar-circulo 10 "solido" "azul-ceu"))

;; 2. Função pura de quadro: gira a estrela no centro e move o cometa pelo céu
(definir (desenhar-quadro t)
  (colocar-figura
   (rotacionar (multiplicar t 4) estrela-central)
   210
   130
   (colocar-figura
    cometa
    (resto-divisao (multiplicar t 6) 420)
    (somar 35 (resto-divisao (multiplicar t 2) 150))
    cenario-com-lua)))

;; 3. Validando que a função produz figuras válidas antes de animar
(verificar-resultado (figura? (desenhar-quadro 0)) verdadeiro)
(verificar-resultado (figura? (desenhar-quadro 30)) verdadeiro)

(mostrar "Abrindo animação espacial! Feche a janela quando quiser encerrar.")

;; 4. Inicia a animação contínua
(criar-animacao desenhar-quadro)
