#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 2
;; @licao: 6
;; @titulo: Arte e Geometria com a Tartaruga (Turtle Graphics)

(mostrar "=== Nível 2 - Lição 6: Arte e Geometria com a Tartaruga ===")

;; 1. Inicia a janela gráfica da Tartaruga (600x600) e define velocidade animada (1 a 10; 0 = instantâneo)
(iniciar-tartaruga)
(velocidade-tartaruga 6)

;; 2. Reconhecimento de padrões e abstração: transição 'definir'/'se'/'verificar-resultado' <-> 'define'/'if'/'check-expect'
;; O ângulo externo de qualquer polígono regular é sempre (360 / lados)
(definir (angulo-poligono-pt lados)
  (se (maior? lados 0)
      (dividir 360 lados)
      0))

(define (angulo-poligono lados)
  (if (maior? lados 0)
      (dividir 360 lados)
      0))

(verificar-resultado (angulo-poligono-pt 4) 90)
(check-expect (angulo-poligono 3) 120)

(definir (poligono lados tamanho)
  (repetir lados vezes
    (avancar tamanho)
    (girar-direita (angulo-poligono lados))))

(define (estrela tamanho)
  (repetir 5 vezes
    (avancar tamanho)
    (girar-direita 144)))

;; 3. Desenhando um Quadrado Azul usando nossa abstração
(mudar-cor "azul")
(mudar-espessura 3)
(poligono 4 100)

;; 4. Movendo a tartaruga sem riscar o papel (levantar caneta)
(levantar-caneta)
(avancar 160)
(abaixar-caneta)

;; 5. Desenhando uma Estrela Dourada de 5 pontas
(mudar-cor "dourado")
(mudar-espessura 4)
(estrela 120)

;; 6. Voltando ao centro para desenhar um Triângulo e um Hexágono
(levantar-caneta)
(voltar-ao-centro)
(ir-para -120 -80)
(abaixar-caneta)

(mudar-cor "vermelho")
(mudar-espessura 2)
(poligono 3 80)

(mudar-cor "verde")
(poligono 6 55)

(mostrar "Arte com a Tartaruga concluída com sucesso! 🐢🎨")
