#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 2
;; @licao: 5
;; @titulo: Jogos, Sorteio, Cenários e Coleções ('repetir', 'lista' & Coordenadas)

(mostrar "=== Nível 2 - Lição 5: Sorteio, Jogos, Cenários e Coleções ===")

;; 1. Usando repetição simples: (repetir N vezes instrução ...)
(mostrar "Sorteando 3 números da sorte para a cartela:")
(repetir 3 vezes
  (mostrar (juntar-texto "Número da sorte: " (sortear-numero 1 60))))

;; 2. Coleções de dados em Português com 'lista' (transição 'defina'/'definir' <-> 'define')
(defina palpites como (lista 5 12 23 34 45 56))
(mostrar (juntar-texto "Total de palpites na lista: " (tamanho-lista palpites)))
(mostrar (juntar-texto "Primeiro palpite: " (primeiro palpites)))
(mostrar (juntar-texto "Palpites invertidos: " (inverter-lista palpites)))

;; 3. Cenário Gráfico e Coordenadas para Jogos com 'desenhar-cenario' e 'colocar-figura'
(definir tela-jogo (desenhar-cenario 280 140 "azul-ceu"))
(definir moeda (desenhar-circulo 22 "solido" "dourado"))
(define texto-jogo (desenhar-texto "Jogo da Moeda Premiada" 14 "azul"))

;; Montando o tabuleiro visual nas coordenadas X e Y
(define tela-com-titulo (colocar-figura texto-jogo 140 25 tela-jogo))
(define tabuleiro-final (colocar-figura moeda 140 85 tela-com-titulo))

(mostrar "Exibindo tabuleiro do mini-jogo:")
tabuleiro-final

;; 4. Jogo de Adivinhação de Moeda (Cara ou Coroa): 'se' e 'if' lado a lado
(definir (lancar-moeda rodada)
  (se (igual? (sortear-numero 1 2) 1)
      (juntar-texto "Rodada " rodada ": 🟡 CARA (Parabéns!)")
      (juntar-texto "Rodada " rodada ": 👑 COROA (Tente outra vez!)")))

(define (premio-rodada acertou?)
  (if acertou?
      "Ganhou 10 pontos!"
      "Tente novamente!"))

(mostrar (lancar-moeda 1))

;; 5. Predicados numéricos: 'escolha' e 'cond' lado a lado, validados com 'verificar-resultado' e 'check-expect'
(definir (analisar-numero n)
  (escolha
   [(e-zero? n) "O número é zero"]
   [(e-par? n) "O número é par"]
   [senao "O número é ímpar"]))

(define (analisar-numero-htdp n)
  (cond
   [(e-zero? n) "O número é zero"]
   [(e-par? n) "O número é par"]
   [else "O número é ímpar"]))

(mostrar (juntar-texto "Análise do número 14: " (analisar-numero 14)))

(verificar-resultado (analisar-numero 0) "O número é zero")
(verificar-resultado (analisar-numero 8) "O número é par")
(check-expect (analisar-numero-htdp 9) "O número é ímpar")
(check-expect (premio-rodada verdadeiro) "Ganhou 10 pontos!")

(mostrar "Testes lógicos do jogo aprovados com sucesso!")
