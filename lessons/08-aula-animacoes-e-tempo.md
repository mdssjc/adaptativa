# Aula 08: Animações como Funções do Tempo
;; @aula: 8
;; @nivel: 3
;; @titulo: Animações como Funções do Tempo ('criar-animacao')

## 🎯 Objetivo Pedagógico
Compreender o movimento digital como uma função matemática pura do tempo (`t -> figura`), conectando coordenadas cartesianas, aritmética modular (`resto-divisao`) e animação contínua com `criar-animacao`.

---

## 📖 1. Motivação e Contexto Didático
No cinema e nos desenhos animados, o movimento nasce de uma sequência rápida de quadros (cerca de 28 imagens por segundo). Na programação funcional, você não precisa desenhar cada quadro à mão: basta escrever uma única função que recebe o instante `t` (0, 1, 2, 3...) e calcula onde cada personagem deve estar naquele momento!

---

## 🛠️ 2. Conceitos e Comandos Principais

### a) Preparando o cenário e o personagem
Primeiro criamos o fundo e a figura que vai se mover (usando `define` e `quotient` do Nível 3 para centralizar o gramado):
```racket
(define largura-ceu 420)
(define ceu (desenhar-cenario largura-ceu 220 "azul-ceu"))
(define gramado (desenhar-retangulo largura-ceu 35 "solido" "verde-escuro"))
(define fundo (colocar-figura gramado (quotient largura-ceu 2) 202 ceu))
(define bola (desenhar-circulo 18 "solido" "vermelho"))
```

### b) Criando a função de cada quadro (`t -> figura`)
A posição horizontal X cresce junto com `t`. Usamos `resto-divisao` pela largura da tela (`420`) e combinamos `if`, `and` e `not` (Nível 3) para variar a altura na segunda metade da tela:
```racket
(define (posicao-x-bola t)
  (resto-divisao (multiplicar t 5) largura-ceu))

(define (desenhar-quadro t)
  (colocar-figura
   bola
   (posicao-x-bola t)
   (if (and (>= (posicao-x-bola t) (quotient largura-ceu 2))
            (not (= t 0)))
       140
       168)
   fundo))
```

### c) Testando um quadro com 'check-expect' e iniciando a animação
Como `desenhar-quadro` é uma função normal, podemos testá-la antes de abrir a janela de animação:
```racket
(check-expect (figura? (desenhar-quadro 0)) verdadeiro)

(criar-animacao desenhar-quadro)
```

---

## 📋 3. Roteiro Prático Passo a Passo
- Passo 1: Crie um cenário de 420x220 pixels e um personagem (bola, carro ou pássaro) usando `define`.
- Passo 2: Escreva `(define (desenhar-quadro t) ...)` calculando a coordenada X a partir de `t`.
- Passo 3: Teste sua função com `(check-expect (figura? (desenhar-quadro 0)) verdadeiro)`.
- Passo 4: Chame `(criar-animacao desenhar-quadro)` e clique em **Executar (Ctrl+R)**.
- Passo 5: Experimente trocar o fator `5` por `2` (mais lento) ou `10` (mais rápido)!

---

## 💡 Dica ao Mediador
Compare `criar-animacao` com um caderninho de folhas (*flipbook*): cada valor de `t` é o número da página. Isso ajuda o aprendiz a perceber que o movimento não é "mágica", mas sim uma relação previsível entre tempo e posição espacial.
