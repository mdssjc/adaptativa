#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 1
;; @licao: 3
;; @titulo: Funções, Cálculos do Cotidiano e Textos

(mostrar "=== Nível 1 - Lição 3: Funções, Cálculos do Cotidiano e Textos ===")

;; 1. Função com múltiplos parâmetros para planejar um passeio em grupo
(definir (valor-por-pessoa total-gasto desconto pessoas)
  (arredondar (dividir (subtrair total-gasto desconto) pessoas)))

(defina custo-onibus como 480)
(defina desconto-grupo como 45)
(defina participantes como 14)

(mostrar (juntar-texto "Valor aproximado por pessoa: R$ "
                       (valor-por-pessoa custo-onibus desconto-grupo participantes)))

;; 2. Comparando orçamentos com 'maximo' e 'minimo'
(mostrar (juntar-texto "Maior orçamento cotado: R$ " (maximo 480 530 450)))
(mostrar (juntar-texto "Menor orçamento cotado: R$ " (minimo 480 530 450)))

;; 3. Geometria do dia a dia com 'quadrado' e 'raiz-quadrada'
(definir (area-quadrada lado)
  (quadrado lado))

(definir (lado-da-area area)
  (raiz-quadrada area))

(mostrar (juntar-texto "Área de uma horta de 6m x 6m: " (area-quadrada 6) " m²"))
(mostrar (juntar-texto "Lado de uma praça de 100 m²: " (lado-da-area 100) " metros"))

;; 4. Conversão e formatação de textos
(defina entrada-usuario como "125")
(defina bonus como 25)
(defina pontos-finais como (somar (texto->numero entrada-usuario) bonus))

(mostrar (juntar-texto "Pontuação convertida e somada: " (numero->texto pontos-finais)))
(mostrar (juntar-texto "Aviso em letras minúsculas: " (texto-minusculo "PASSEIO CONFIRMADO!")))
