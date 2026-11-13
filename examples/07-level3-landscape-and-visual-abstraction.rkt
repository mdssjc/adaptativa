#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 3
;; @licao: 7
;; @titulo: Abstração Visual Complexa (Paisagem, Cenários & Coordenadas)

(mostrar "=== Nível 3 - Lição 7: Abstração Visual, Cenários e Coordenadas ===")
(mostrar "Construindo uma paisagem completa com casa, sol, árvore e coordenadas X e Y.")

;; 1. Componentes da casa (usando 'define' do Nível 2 e funções matemáticas do Nível 3)
(define parede (desenhar-quadrado 70 "solido" "azul"))
(define porta (desenhar-retangulo 18 32 "solido" "marrom"))
(define janela (desenhar-quadrado 18 "solido" "branco"))
(define telhado (desenhar-triangulo 80 "solido" "vermelho"))

;; Fachada com sobreposições
(define parede-detalhada
  (sobrepor (lado-a-lado janela (desenhar-retangulo 14 1 "solido" "azul") porta)
            parede))

(define casinha-completa
  (acima-de telhado parede-detalhada))

;; 2. Elementos naturais e astronômicos com abstração parametrizada
(define sol
  (sobrepor (desenhar-circulo 18 "solido" "laranja")
            (desenhar-circulo 28 "solido" "amarelo")))

;; Uma função que cria árvores variadas a partir do tamanho e da cor da copa
(define (criar-arvore raio-copa cor-copa)
  (acima-de (desenhar-circulo raio-copa "solido" cor-copa)
            (desenhar-retangulo 12 25 "solido" "marrom")))

(define arvore-grande (criar-arvore 30 "verde"))
(define arvore-pequena (criar-arvore 20 "verde-escuro"))

;; Validação de proporção usando 'and' e 'not' (Nível 3) e 'check-expect' (Nível 2)
(define (figura-visivel? fig)
  (and (figura? fig)
       (not (e-zero? (largura-figura fig)))
       (not (e-zero? (altura-figura fig)))))

(check-expect (figura-visivel? casinha-completa) verdadeiro)
(check-expect (quotient 420 2) 210)

(mostrar (juntar-texto "Dimensões da casa: "
                       (largura-figura casinha-completa) "x"
                       (altura-figura casinha-completa) "px"))

;; 3. Montagem da cena espacial panorâmica com 'desenhar-cenario' e 'colocar-figura'
(define largura-tela 420)
(define cenario-base (desenhar-cenario largura-tela 260 "azul-ceu"))

;; Adiciona o gramado centralizado horizontalmente usando 'quotient' (divisão inteira)
(define gramado (desenhar-retangulo largura-tela 30 "solido" "verde-escuro"))
(define cenario-com-solo (colocar-figura gramado (quotient largura-tela 2) 245 cenario-base))

;; Posiciona Sol, Casa, Árvores e Título em coordenadas precisas
(define cena-1 (colocar-figura sol 350 60 cenario-com-solo))
(define cena-2 (colocar-figura casinha-completa 140 170 cena-1))
(define cena-3 (colocar-figura arvore-grande 290 175 cena-2))
(define cena-4 (colocar-figura arvore-pequena 355 188 cena-3))

(define titulo-assinatura
  (desenhar-texto "Casa do Idoso Sul - Oficina de Criação Digital" 14 "azul"))

(define quadro-final
  (colocar-figura titulo-assinatura (quotient largura-tela 2) 20 cena-4))

(mostrar "Quadro artístico montado:")
quadro-final
