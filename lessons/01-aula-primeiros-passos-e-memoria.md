# Aula 01: Primeiros Passos, Memória e Variáveis
;; @aula: 1
;; @nivel: 1
;; @titulo: Primeiros Passos, Memória e Variáveis

## 🎯 Objetivo Pedagógico
Apresentar o computador como um colaborador que armazena informações em caixas de memória, interage com o usuário e executa instruções passo a passo com clareza e previsibilidade.

---

## 📖 1. Motivação e Contexto Didático
Imagine que você tem várias caixas etiquetadas na sua estante:
- Uma caixa com a etiqueta **"meu-nome"** onde guardamos seu nome.
- Uma caixa **"ano-atual"** onde guardamos o ano em que estamos.

Na programação, essas caixas são chamadas de **VARIÁVEIS** ou **CONSTANTES**. Elas ensinam o computador a lembrar das informações importantes que usaremos em nossos cálculos, conversas e receitas!

---

## 🛠️ 2. Conceitos e Comandos Principais

### a) Exibir mensagens na tela
Use a instrução `(mostrar ...)` para conversar com o usuário:
```racket
(mostrar "Olá! Seja bem-vindo(a) à informática criativa!")
```

### b) Criar caixas de memória
Use `(defina nome como valor)` para guardar informações:
```racket
(defina meu-nome como "Dona Maria")
(defina meta-diaria como 3000)
(mostrar meu-nome)
(mostrar meta-diaria)
```

### c) Juntando textos com 'juntar-texto'
Você pode unir frases, palavras e números facilmente sem complicação:
```racket
(mostrar (juntar-texto "Olá, " meu-nome "! Sua meta diária é de " meta-diaria " passos."))
(mostrar (juntar-texto "Tamanho do seu nome: " (tamanho-texto meu-nome) " letras."))
```

### d) Conversando com o usuário: via Janela (Popup) ou Terminal
O ambiente oferece duas formas de interagir e ler dados do usuário:

#### 1. Via Janela Amigável (Popup Modal)
Ideal para aprendizes da terceira idade que preferem caixas visuais:
```racket
(defina cidade-favorita como (pedir-texto "Qual é a sua cidade favorita?"))
(mostrar (juntar-texto "Que maravilhoso! Você adora a cidade de " cidade-favorita "."))
```

#### 2. Diretamente no Terminal / Área de Interações
Ideal para quem prefere digitar as respostas diretamente na linha de comando ou console inferior:
```racket
(defina fruta-favorita como (ler-linha "Digite sua fruta favorita: "))
(mostrar (juntar-texto "Excelente escolha! A fruta é: " fruta-favorita "."))
```
*(Você também pode usar o comando alternativo `ler-texto` com o mesmo comportamento).*

### e) Consultar e calcular com a memória
Podemos somar o conteúdo de duas caixas:
```racket
(defina passos-manha como 1200)
(defina passos-tarde como 1800)
(defina total-passos como (somar passos-manha passos-tarde))
(mostrar (juntar-texto "Total de passos hoje: " total-passos))
```

### f) Criando sua primeira função (receita reutilizável)
Uma função ensina uma receita ao computador para ser usada sempre que precisar. Vamos criar nossa própria função com o nome `somar-valores`:
```racket
(definir (somar-valores a b)
  (somar a b))

(mostrar (juntar-texto "Resultado da soma: " (somar-valores 45 35)))
```

---

## 📋 3. Roteiro Prático Passo a Passo
- Passo 1: No topo do DrRacket, certifique-se de que a primeira linha é `#lang adaptativa`.
- Passo 2: Escreva uma saudação inicial usando `(mostrar "...")`.
- Passo 3: Crie uma caixa de memória com seu hobby ou cidade favorita: `(defina meu-hobby como "Jardinagem")`.
- Passo 4: Experimente usar `(juntar-texto "Meu passatempo predileto é " meu-hobby)` e exiba com `(mostrar ...)`.
- Passo 5: Clique em **Executar (Ctrl+R)** e veja a resposta surgir no console inferior!

---

## 💡 Dica ao Mediador
Conduza os participantes a pensarem em suas próprias memórias e histórias para guardar nas variáveis. A função `juntar-texto` dá grande autonomia para formularem frases afetivas completas.
