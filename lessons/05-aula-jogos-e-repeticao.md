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

### b) Sorteando números aleatórios e decidindo ('se'/'if' e 'verificar-resultado'/'check-expect')
Gere números da sorte entre um valor mínimo e máximo e pratique a transição entre português e HtDP no Nível 2:
```racket
(defina sorteio como (sortear-numero 1 60))
(mostrar (juntar-texto "Número sorteado da rodada: " sorteio))

;; Em português:
(definir (resultado-dado-pt valor)
  (se (maior? valor 3)
      "Avance 2 casas!"
      "Avance 1 casa!"))

;; Equivalente em HtDP (Nível 2):
(define (resultado-dado valor)
  (if (maior? valor 3)
      "Avance 2 casas!"
      "Avance 1 casa!"))

(verificar-resultado (resultado-dado-pt 5) "Avance 2 casas!")
(check-expect (resultado-dado 5) "Avance 2 casas!")
```

### c) Coleções de dados em Português com 'lista'
Podemos guardar múltiplos valores em uma única coleção:
```racket
(define numeros-favoritos (lista 7 14 21 28))
(mostrar (juntar-texto "Quantidade de números: " (tamanho-lista numeros-favoritos)))
(mostrar (juntar-texto "Primeiro número: " (primeiro numeros-favoritos)))
```

### d) Criando tabuleiros e jogos visuais com 'desenhar-cenario' e 'colocar-figura'
Podemos criar um cenário com dimensões exatas e colocar personagens em posições (X, Y):
```racket
(define tabuleiro (desenhar-cenario 300 200 "azul-ceu"))
(define jogador (desenhar-circulo 20 "solido" "amarelo"))
(define premio (desenhar-estrela 18 "solido" "dourado"))

;; Posicionando o jogador no ponto X=50, Y=100
(define cena-1 (colocar-figura jogador 50 100 tabuleiro))

;; Posicionando o prêmio no ponto X=250, Y=100
(define cena-jogo (colocar-figura premio 250 100 cena-1))

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
