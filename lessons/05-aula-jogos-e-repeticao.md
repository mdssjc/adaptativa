# Aula 05: Sorteio, Jogos, Cenários e Coleções ('repetir' & 'lista')
;; @aula: 5
;; @nivel: 2
;; @titulo: Sorteio, Jogos, Cenários e Coleções ('repetir' & 'lista')

## 🎯 Objetivo Pedagógico
Apresentar a aleatoriedade lúdica, laços de repetição, coleções de dados (`lista`) e cenários gráficos (`desenhar-cenario`, `colocar-figura`) para construir pequenos jogos visuais interativos.

---

## 📖 1. Motivação e Contexto Didático
Computadores são fantásticos porque conseguem repetir ações centenas de vezes sem cansar, sortear números da sorte para uma cartela de Bingo e posicionar peças em um tabuleiro de jogo em coordenadas exatas (X, Y)!

---

## 🛠️ 2. Conceitos e Comandos Principais

### a) Repetindo ações com 'repetir'
Use a instrução `(repetir N vezes ...)` para executar algo repetidamente:
```racket
(repetir 3 vezes
  (mostrar "Bom dia! Viva o aprendizado ativo!"))
```

### b) Sorteando números aleatórios
Gere números da sorte entre um valor mínimo e máximo:
```racket
(defina sorteio como (sortear-numero 1 60))
(mostrar (juntar-texto "Número sorteado da rodada: " sorteio))
```

### c) Coleções de dados em Português com 'lista'
Podemos guardar múltiplos valores em uma única coleção:
```racket
(defina numeros-favoritos como (lista 7 14 21 28))
(mostrar (juntar-texto "Quantidade de números: " (tamanho-lista numeros-favoritos)))
(mostrar (juntar-texto "Primeiro número: " (primeiro numeros-favoritos)))
```

### d) Criando tabuleiros e jogos visuais com 'desenhar-cenario' e 'colocar-figura'
Podemos criar um cenário com dimensões exatas e colocar personagens em posições (X, Y):
```racket
(defina tabuleiro como (desenhar-cenario 300 200 "azul-ceu"))
(defina jogador como (desenhar-circulo 20 "solido" "amarelo"))
(defina premio como (desenhar-estrela 18 "solido" "dourado"))

;; Posicionando o jogador no ponto X=50, Y=100
(defina cena-1 como (colocar-figura jogador 50 100 tabuleiro))

;; Posicionando o prêmio no ponto X=250, Y=100
(defina cena-jogo como (colocar-figura premio 250 100 cena-1))

cena-jogo
```

---

## 📋 3. Roteiro Prático Passo a Passo
- Passo 1: Crie um cenário de jogo com `(desenhar-cenario 300 150 "verde")`.
- Passo 2: Crie um personagem com `(desenhar-circulo 25 "solido" "azul")`.
- Passo 3: Coloque o personagem no centro com `(colocar-figura personagem 150 75 cenario)`.
- Passo 4: Sorteie um número da sorte com `(sortear-numero 1 100)` e mostre com `juntar-texto`.
- Passo 5: Execute com **Ctrl+R** e veja seu mini-jogo visual na tela!

---

## 💡 Dica ao Mediador
Proponha aos aprendizes criarem cartelas de bingo visuais ou um sorteio de amigo secreto. A dinâmica em grupo torna a aula de repetição e cenários muito divertida e participativa.
