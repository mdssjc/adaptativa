#lang adaptativa

;;; Metadados do Exemplo Educativo:
;; @nivel: 1
;; @licao: 1
;; @titulo: Primeiros Passos, Memória e Textos (Variáveis, Diálogo & Cálculos)

(mostrar "=== Nível 1 - Lição 1: Primeiros Passos e Memória ===")

;; 1. Mensagens na tela com (mostrar ...)
(mostrar "Olá! Bem-vindo(a) à programação com a Linguagem Adaptativa!")

;; 2. Criando caixas de memória (constantes/variáveis)
;; Use 'defina ... como ...' para dar nomes a valores importantes
(defina meu-nome como "Maria")
(defina minha-idade como 68)
(defina meta-diaria-passos como 3000)

(mostrar (juntar-texto "Aprendiz: " meu-nome " | Idade: " minha-idade " anos"))
(mostrar (juntar-texto "Meta de passos: " meta-diaria-passos))

;; 3. Manipulação de texto em Português com 'juntar-texto' e 'tamanho-texto'
(mostrar (juntar-texto "Seu nome possui " (tamanho-texto meu-nome) " letras."))
(mostrar (juntar-texto "Nome em destaque: " (texto-maiusculo meu-nome)))

;; 4. Fazendo cálculos do dia a dia
(defina passos-manha como 1250)
(defina passos-tarde como 1800)
(defina total-passos como (somar passos-manha passos-tarde))

(mostrar (juntar-texto "Total de passos caminhados hoje: " total-passos))

;; 5. Criando nossa primeira função de cálculo
;; Funções ensinam o computador a realizar uma receita sempre que precisarmos
(definir (somar-valores a b)
  (somar a b))

(mostrar (juntar-texto "Somando valores de compras: R$ " (somar-valores 45 32)))

;; 💡 Dicas de Interação com o Usuário (Duas formas disponíveis):
;; 1. Via Janela Popup:
;;    (defina flor como (pedir-texto "Qual é a sua flor favorita?"))
;; 2. Diretamente no Terminal / Área de Interações:
;;    (defina flor como (ler-linha "Digite sua flor favorita: "))
;; (mostrar (juntar-texto "Que lindo! Você gosta de " flor "!"))
