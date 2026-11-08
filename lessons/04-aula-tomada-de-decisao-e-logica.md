# Aula 04: Tomada de Decisão, Condicionais e Testes
;; @aula: 4
;; @nivel: 2
;; @titulo: Tomada de Decisão, Condicionais ('se') e Testes

## 🎯 Objetivo Pedagógico
Ensinar o computador a tomar decisões com base em perguntas lógicas, formular diálogos inteligentes com o usuário e introduzir a prática científica de validação com testes automatizados.

---

## 📖 1. Motivação e Contexto Didático
No cotidiano tomamos decisões a todo momento:
- *"Se a temperatura estiver acima de 28 graus, levo água fresca; caso contrário, levo um agasalho leve."*

O comando `(se condicao caso-sim caso-nao)` ensina essa mesma lógica ao computador!

---

## 🛠️ 2. Conceitos e Comandos Principais

### a) O desvio condicional 'se'
O computador avalia a condição e escolhe qual caminho seguir:
```racket
(definir (avaliar-temperatura graus)
  (se (maior-ou-igual? graus 28)
      "Dia ensolarado: use protetor solar e beba água!"
      "Clima ameno: aproveite para um passeio agradável!"))

(mostrar (juntar-texto "Previsão para 31°C: " (avaliar-temperatura 31)))
(mostrar (juntar-texto "Previsão para 22°C: " (avaliar-temperatura 22)))
```

### b) Múltiplas escolhas com 'escolha' e lógica composta ('e', 'ou', 'nao')
Quando há mais de dois caminhos possíveis, usamos `escolha` com `senao`, e podemos combinar perguntas com `e`, `ou` e `nao`:
```racket
(definir (semaforo-saude batimentos)
  (escolha
   [(menor? batimentos 60) "Abaixo do padrão de repouso"]
   [(menor-ou-igual? batimentos 100) "Ritmo cardíaco em repouso normal"]
   [senao "Ritmo acelerado - consulte o instrutor"]))

(definir (repouso-saudavel? batimentos)
  (e (maior-ou-igual? batimentos 60)
     (menor-ou-igual? batimentos 100)))
```

### c) Predicados úteis em Português
Perguntas lógicas que respondem verdadeiro ou falso:
```racket
(igual? 10 10)       ; verdadeiro
(diferente? 5 8)     ; verdadeiro
(maior? 20 15)       ; verdadeiro
(menor? 7 12)        ; verdadeiro
(e-par? 4)           ; verdadeiro
(e-impar? 7)         ; verdadeiro
(e-positivo? 10)     ; verdadeiro
```

### d) Diálogo interativo: lendo números via Janela ou Terminal
Podemos criar um assistente virtual que pergunta a temperatura ao usuário e responde na hora:

- **Via Janela Popup (`pedir-numero`):**
  ```racket
  (defina temp-digitada como (pedir-numero "Qual a temperatura atual em sua cidade?"))
  (mostrar (juntar-texto "Orientação do dia: " (avaliar-temperatura temp-digitada)))
  ```

- **Via Terminal / Console (`ler-numero`):**
  ```racket
  (defina temp-digitada como (ler-numero "Digite a temperatura atual (°C): "))
  (mostrar (juntar-texto "Orientação do dia: " (avaliar-temperatura temp-digitada)))
  ```

### e) Validação com testes automatizados ('verificar-resultado')
Comprove cientificamente que sua função funciona em todos os cenários:
```racket
(verificar-resultado (avaliar-temperatura 30) "Dia ensolarado: use protetor solar e beba água!")
(verificar-resultado (avaliar-temperatura 20) "Clima ameno: aproveite para um passeio agradável!")
(verificar-resultado (repouso-saudavel? 75) verdadeiro)
```
> 🌟 **Bônus Pedagógico:** Cada teste aprovado garante **+2 pontos extras** automaticamente para o seu perfil!

---

## 📋 3. Roteiro Prático Passo a Passo
- Passo 1: Escreva a função `(avaliar-temperatura graus)` no seu arquivo.
- Passo 2: Teste a função com valores diferentes: 32 e 19 graus.
- Passo 3: Adicione um `(verificar-resultado ...)` para comprovar a resposta esperada.
- Passo 4: Execute com **Ctrl+R** e veja sua pontuação e nível avançando no placar!

---

## 💡 Dica ao Mediador
Mostre aos alunos que errar o teste não quebra o computador; pelo contrário, o teste serve como um cinto de segurança que avisa com precisão onde ajustar a lógica.
