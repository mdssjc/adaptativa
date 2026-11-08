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
Primeiro criamos o fundo e a figura que vai se mover:
```racket
(defina ceu como (desenhar-cenario 420 220 "azul-ceu"))
(defina gramado como (desenhar-retangulo 420 35 "solido" "verde-escuro"))
(defina fundo como (colocar-figura gramado 210 202 ceu))
(defina bola como (desenhar-circulo 18 "solido" "vermelho"))
```

### b) Criando a função de cada quadro (`t -> figura`)
A posição horizontal X cresce junto com `t`. Usamos `resto-divisao` pela largura da tela (`420`) para que a bola reapareça do lado esquerdo ao chegar à borda direita:
```racket
(definir (desenhar-quadro t)
  (colocar-figura bola (resto-divisao (multiplicar t 5) 420) 168 fundo))
```

### c) Testando um quadro e iniciando a animação
Como `desenhar-quadro` é uma função normal, podemos testá-la antes de abrir a janela de animação:
```racket
(verificar-resultado (figura? (desenhar-quadro 0)) verdadeiro)

(criar-animacao desenhar-quadro)
```

---

## 📋 3. Roteiro Prático Passo a Passo
- Passo 1: Crie um cenário de 420x220 pixels e um personagem (bola, carro ou pássaro).
- Passo 2: Escreva `(definir (desenhar-quadro t) ...)` calculando a coordenada X a partir de `t`.
- Passo 3: Teste sua função com `(verificar-resultado (figura? (desenhar-quadro 0)) verdadeiro)`.
- Passo 4: Chame `(criar-animacao desenhar-quadro)` e clique em **Executar (Ctrl+R)**.
- Passo 5: Experimente trocar o fator `5` por `2` (mais lento) ou `10` (mais rápido)!

---

## 💡 Dica ao Mediador
Compare `criar-animacao` com um caderninho de folhas (*flipbook*): cada valor de `t` é o número da página. Isso ajuda o aprendiz a perceber que o movimento não é "mágica", mas sim uma relação previsível entre tempo e posição espacial.
