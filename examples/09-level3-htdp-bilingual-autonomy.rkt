#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 3
;; @licao: 9
;; @titulo: Autonomia HtDP & Transição Bilíngue ('define-struct', 'cond', 'check-expect')

(mostrar "=== Nível 3 - Lição 9: Transição Bilíngue e Autonomia HtDP ===")
(mostrar "Exemplo prático de orçamento da feira usando a sintaxe oficial do HtDP!")

;; 1. Modelagem de dados compostos com define-struct
(define-struct item (nome preco))

(define cesta-feira
  (list (make-item "Maçã" 8)
        (make-item "Café" 18)
        (make-item "Pão" 7)
        (make-item "Queijo" 22)))

;; 2. Recursão estrutural sobre a lista de itens (Design Recipe do HtDP)
(define (somar-cesta itens)
  (cond
    [(empty? itens) 0]
    [else (+ (item-preco (first itens))
             (somar-cesta (rest itens)))]))

;; 3. Decisão com 'if', 'cond' e lógica booleana do Nível 3 ('and', 'or', 'not')
(define (faixa-saudavel? total)
  (and (>= total 20)
       (not (> total 100))))

(define (tem-desconto-especial? total quantidade)
  (or (>= total 50)
      (>= quantidade 5)))

(define (aplicar-desconto total)
  (if (tem-desconto-especial? total (length cesta-feira))
      (- total 10)
      total))

(define (resumo-compra total)
  (cond
    [(<= total 30) "Compra econômica"]
    [(<= total 60) "Compra equilibrada"]
    [else "Compra grande - confira a lista"]))

;; 4. Matemática avançada do Nível 3 ('sqr', 'expt', 'quotient')
(define (parcela-inteira total parcelas)
  (quotient total parcelas))

(define (bonus-fidelidade nivel-clube)
  (+ (sqr nivel-clube) (expt 2 nivel-clube)))

(define total-bruto (somar-cesta cesta-feira))
(define total-final (aplicar-desconto total-bruto))

(mostrar (juntar-texto "Quantidade de itens na cesta: " (length cesta-feira)))
(mostrar (juntar-texto "Primeiro item: " (item-nome (first cesta-feira))))
(mostrar (juntar-texto "Total bruto: R$ " total-bruto))
(mostrar (juntar-texto "Total com desconto: R$ " total-final))
(mostrar (juntar-texto "Em 3x inteiras de: R$ " (parcela-inteira total-final 3)))
(mostrar (juntar-texto "Bônus fidelidade (nível 3): " (bonus-fidelidade 3) " pontos"))
(mostrar (juntar-texto "Avaliação: " (resumo-compra total-final)))

;; 5. Bateria de testes oficiais com check-expect
(check-expect (somar-cesta empty) 0)
(check-expect (somar-cesta cesta-feira) 55)
(check-expect (faixa-saudavel? 45) verdadeiro)
(check-expect (faixa-saudavel? 120) falso)
(check-expect (tem-desconto-especial? 30 5) verdadeiro)
(check-expect (aplicar-desconto 40) 40)
(check-expect (aplicar-desconto 55) 45)
(check-expect (parcela-inteira 45 3) 15)
(check-expect (bonus-fidelidade 3) 17)
(check-expect (resumo-compra 45) "Compra equilibrada")

(mostrar "Parabéns! Você concluiu o percurso até a autonomia completa com o HtDP!")
