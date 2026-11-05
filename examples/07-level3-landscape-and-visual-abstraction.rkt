#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 3
;; @licao: 7
;; @titulo: Abstração Visual Complexa (Paisagem, Cenários & Coordenadas)

(mostrar "=== Nível 3 - Lição 7: Abstração Visual, Cenários e Coordenadas ===")
(mostrar "Construindo uma paisagem completa com casa, sol, árvore e coordenadas X e Y.")

;; 1. Componentes da casa
(definir parede (desenhar-quadrado 70 "solido" "azul"))
(definir porta (desenhar-retangulo 18 32 "solido" "marrom"))
(definir janela (desenhar-quadrado 18 "solido" "branco"))
(definir telhado (desenhar-triangulo 80 "solido" "vermelho"))

;; Fachada com sobreposições
(definir parede-detalhada
  (sobrepor (lado-a-lado janela (desenhar-retangulo 14 1 "solido" "azul") porta)
            parede))

(definir casinha-completa
  (acima-de telhado parede-detalhada))

;; 2. Elementos naturais e astronômicos com abstração parametrizada
(definir sol
  (sobrepor (desenhar-circulo 18 "solido" "laranja")
            (desenhar-circulo 28 "solido" "amarelo")))

;; Uma função que cria árvores variadas a partir do tamanho e da cor da copa
(definir (criar-arvore raio-copa cor-copa)
  (acima-de (desenhar-circulo raio-copa "solido" cor-copa)
            (desenhar-retangulo 12 25 "solido" "marrom")))

(definir arvore-grande (criar-arvore 30 "verde"))
(definir arvore-pequena (criar-arvore 20 "verde-escuro"))

(mostrar (juntar-texto "Dimensões da casa: "
                       (largura-figura casinha-completa) "x"
                       (altura-figura casinha-completa) "px"))

;; 3. Montagem da cena espacial panorâmica com 'desenhar-cenario' e 'colocar-figura'
(definir cenario-base (desenhar-cenario 420 260 "azul-ceu"))

;; Adiciona o gramado no rodapé
(definir gramado (desenhar-retangulo 420 30 "solido" "verde-escuro"))
(definir cenario-com-solo (colocar-figura gramado 210 245 cenario-base))

;; Posiciona Sol, Casa, Árvores e Título em coordenadas precisas
(definir cena-1 (colocar-figura sol 350 60 cenario-com-solo))
(definir cena-2 (colocar-figura casinha-completa 140 170 cena-1))
(definir cena-3 (colocar-figura arvore-grande 290 175 cena-2))
(definir cena-4 (colocar-figura arvore-pequena 355 188 cena-3))

(definir titulo-assinatura
  (desenhar-texto "Casa do Idoso Sul - Oficina de Criação Digital" 14 "azul"))

(definir quadro-final
  (colocar-figura titulo-assinatura 210 20 cena-4))

(mostrar "Quadro artístico montado:")
quadro-final
