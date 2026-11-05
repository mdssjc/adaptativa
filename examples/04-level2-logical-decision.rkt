#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 2
;; @licao: 4
;; @titulo: Tomada de Decisão Lógica ('se', 'escolha' & Testes)

(mostrar "=== Nível 2 - Lição 4: Tomada de Decisão com 'se' e 'escolha' ===")

;; 1. Condicional com (se condicao caso-sim caso-nao)
;; O computador decide qual caminho seguir dependendo do resultado do teste
(definir (avaliar-temperatura graus)
  (se (maior-ou-igual? graus 28)
      "Dia ensolarado e quente: use protetor solar e beba água!"
      "Clima ameno ou fresco: aproveite para um passeio agradável!"))

(mostrar (juntar-texto "Previsão para 31 graus: " (avaliar-temperatura 31)))
(mostrar (juntar-texto "Previsão para 22 graus: " (avaliar-temperatura 22)))

;; 2. Múltiplas escolhas com (escolha ...)
(definir (semaforo-saude batimentos)
  (escolha
   [(menor? batimentos 60) "Abaixo do padrão de repouso"]
   [(menor-ou-igual? batimentos 100) "Ritmo cardíaco em repouso normal"]
   [senao "Ritmo acelerado - consulte o instrutor"]))

(mostrar (juntar-texto "Status com 75 bpm: " (semaforo-saude 75)))

;; 3. Combinando condições com lógica booleana ('e', 'ou', 'nao')
(definir (repouso-saudavel? batimentos)
  (e (maior-ou-igual? batimentos 60)
     (menor-ou-igual? batimentos 100)))

;; 4. Validação garantida com testes automatizados:
;; Testes garantem que o programa funciona com precisão matemática
(verificar-resultado (avaliar-temperatura 30) "Dia ensolarado e quente: use protetor solar e beba água!")
(verificar-resultado (semaforo-saude 70) "Ritmo cardíaco em repouso normal")
(verificar-resultado (repouso-saudavel? 75) verdadeiro)
(verificar-resultado (repouso-saudavel? 115) falso)

(mostrar "Todos os testes lógicos foram validados com sucesso!")

;; 💡 Dicas de Leitura de Números (Duas formas disponíveis):
;; 1. Via Janela Popup:
;;    (defina bpm-usuario como (pedir-numero "Qual a sua frequência cardíaca em repouso?"))
;; 2. Diretamente no Terminal / Área de Interações:
;;    (defina bpm-usuario como (ler-numero "Digite a frequência cardíaca (bpm): "))
;; (mostrar (juntar-texto "Seu diagnóstico: " (semaforo-saude bpm-usuario)))
