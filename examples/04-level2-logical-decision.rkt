#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 2
;; @licao: 4
;; @titulo: Tomada de Decisão Lógica ('define', 'if', 'cond' & 'check-expect')

(mostrar "=== Nível 2 - Lição 4: Tomada de Decisão com 'if', 'cond' e 'check-expect' ===")

;; 1. Condicional: forma em português ('definir' + 'se') e forma HtDP ('define' + 'if')
(definir (avaliar-temperatura graus)
  (se (maior-ou-igual? graus 28)
      "Dia ensolarado e quente: use protetor solar e beba água!"
      "Clima ameno ou fresco: aproveite para um passeio agradável!"))

(define (temperatura-alta? graus)
  (if (maior-ou-igual? graus 28)
      verdadeiro
      falso))

(mostrar (juntar-texto "Previsão para 31 graus: " (avaliar-temperatura 31)))
(mostrar (juntar-texto "Previsão para 22 graus: " (avaliar-temperatura 22)))

;; 2. Múltiplas escolhas: forma em português ('escolha'/'senao') e forma HtDP ('cond'/'else')
(definir (semaforo-saude batimentos)
  (escolha
   [(menor? batimentos 60) "Abaixo do padrão de repouso"]
   [(menor-ou-igual? batimentos 100) "Ritmo cardíaco em repouso normal"]
   [senao "Ritmo acelerado - consulte o instrutor"]))

(define (semaforo-saude-htdp batimentos)
  (cond
   [(menor? batimentos 60) "Abaixo do padrão de repouso"]
   [(menor-ou-igual? batimentos 100) "Ritmo cardíaco em repouso normal"]
   [else "Ritmo acelerado - consulte o instrutor"]))

(mostrar (juntar-texto "Status com 75 bpm: " (semaforo-saude 75)))

;; 3. Combinando condições com lógica booleana em português ('e', 'ou', 'nao')
;; (As formas em inglês 'and', 'or', 'not' serão desbloqueadas no Nível 3!)
(define (repouso-saudavel? batimentos)
  (e (maior-ou-igual? batimentos 60)
     (menor-ou-igual? batimentos 100)))

;; 4. Validação garantida com as duas formas de teste: 'verificar-resultado' e 'check-expect'
(verificar-resultado (avaliar-temperatura 30) "Dia ensolarado e quente: use protetor solar e beba água!")
(verificar-resultado (semaforo-saude 70) "Ritmo cardíaco em repouso normal")
(check-expect (temperatura-alta? 30) verdadeiro)
(check-expect (semaforo-saude-htdp 70) "Ritmo cardíaco em repouso normal")
(check-expect (repouso-saudavel? 75) verdadeiro)
(check-expect (repouso-saudavel? 115) falso)

(mostrar "Todos os testes lógicos foram validados com sucesso!")

;; 💡 Dicas de Leitura de Números (Duas formas disponíveis):
;; 1. Via Janela Popup:
;;    (defina bpm-usuario como (pedir-numero "Qual a sua frequência cardíaca em repouso?"))
;; 2. Diretamente no Terminal / Área de Interações:
;;    (defina bpm-usuario como (ler-numero "Digite a frequência cardíaca (bpm): "))
;; (mostrar (juntar-texto "Seu diagnóstico: " (semaforo-saude bpm-usuario)))
