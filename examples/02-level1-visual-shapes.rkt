#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 1
;; @licao: 2
;; @titulo: Primeiras Formas e Cores (Abstração Visual & Dimensões)

(mostrar "=== Nível 1 - Lição 2: Primeiras Formas e Cores ===")
(mostrar "Programar também é desenhar e expressar ideias visuais!")

;; 1. Criando formas geométricas elementares com cores em português
;; Primitivas: desenhar-circulo, desenhar-quadrado, desenhar-retangulo, desenhar-triangulo, desenhar-estrela
(definir sol-dourado
  (desenhar-circulo 35 "solido" "amarelo"))

(definir gramado
  (desenhar-retangulo 220 40 "solido" "verde"))

(definir flor-miolo
  (desenhar-circulo 10 "solido" "laranja"))

(definir flor-completa
  (sobrepor flor-miolo (desenhar-circulo 22 "solido" "rosa")))

(definir estrela-brilhante
  (desenhar-estrela 25 "solido" "azul"))

;; 2. Inspecionando dimensões com largura-figura e altura-figura
(mostrar (juntar-texto "Largura do Sol: " (largura-figura sol-dourado) "px"))
(mostrar (juntar-texto "Largura do gramado: " (largura-figura gramado) "px"))

;; 3. Compondo formas no espaço:
;; - (acima-de a b) coloca 'a' em cima de 'b'
;; - (lado-a-lado a b) coloca um ao lado do outro
;; - (sobrepor a b) sobrepõe as figuras pelo centro
(definir ceu-com-sol
  (lado-a-lado sol-dourado (desenhar-retangulo 40 10 "solido" "branco") flor-completa estrela-brilhante))

(definir cena-inicial
  (acima-de ceu-com-sol gramado))

(mostrar (juntar-texto "Dimensões totais da cena: "
                       (largura-figura cena-inicial) "x"
                       (altura-figura cena-inicial) " pixels"))

(mostrar "Exibindo a cena construída:")
cena-inicial

;; 💡 Desafio: Mude a cor do sol ou crie uma nova forma ao lado do gramado!
