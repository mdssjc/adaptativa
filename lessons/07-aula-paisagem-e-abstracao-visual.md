# Aula 07: Paisagem Completa, Cenários e Coordenadas Visuais
;; @aula: 7
;; @nivel: 3
;; @titulo: Paisagem Completa, Cenários e Coordenadas Visuais

## 🎯 Objetivo Pedagógico
Integrar abstrações geométricas modulares em uma cena artística completa através de cenários (`desenhar-cenario`), posicionamento por coordenadas cartesianas (`colocar-figura`) e inspeção de proporção (`largura-figura`, `altura-figura`).

---

## 📖 1. Motivação e Contexto Didático
No Nível 3, o aprendiz passa a atuar como um verdadeiro arquiteto digital: cada parte da cena (janelas, portas, telhado, árvores e sol) é uma peça independente posicionada com precisão no cenário através das coordenadas **X (horizontal)** e **Y (vertical)**!

---

## 🛠️ 2. Conceitos e Comandos Principais

### a) Modelando os blocos da casa
Construa componentes modulares usando `define`:
```racket
(define parede (desenhar-quadrado 70 "solido" "azul"))
(define porta (desenhar-retangulo 18 32 "solido" "marrom"))
(define janela (desenhar-quadrado 18 "solido" "branco"))
(define telhado (desenhar-triangulo 80 "solido" "vermelho"))
```

### b) Fachada com sobreposição e validação (Nível 3)
Posicione janela e porta sobre a parede e valide as dimensões com `and`, `not` e `check-expect`:
```racket
(define fachada
  (sobrepor (lado-a-lado janela (desenhar-retangulo 14 1 "solido" "azul") porta)
            parede))

(define casa-pronta
  (acima-de telhado fachada))

(define (figura-visivel? fig)
  (and (figura? fig)
       (not (e-zero? (largura-figura fig)))))

(check-expect (figura-visivel? casa-pronta) verdadeiro)
```

### c) Montando a paisagem com 'desenhar-cenario', 'colocar-figura' e 'quotient'
Crie uma tela de pintura com céu e posicione cada elemento nas coordenadas desejadas (usando `quotient` do Nível 3 para dividir a largura inteira por 2):
```racket
(define sol
  (sobrepor (desenhar-circulo 15 "solido" "laranja")
            (desenhar-circulo 25 "solido" "amarelo")))

;; Abstração parametrizada: cria árvores de tamanhos e cores diferentes
(define (criar-arvore raio-copa cor-copa)
  (acima-de (desenhar-circulo raio-copa "solido" cor-copa)
            (desenhar-retangulo 12 25 "solido" "marrom")))

(define arvore-grande (criar-arvore 25 "verde"))
(define arvore-pequena (criar-arvore 18 "verde-escuro"))

;; Cria tela de 400x250 pixels com fundo azul céu
(define largura-tela 400)
(define tela (desenhar-cenario largura-tela 250 "azul-ceu"))

;; Posiciona o sol no canto superior direito (X=330, Y=60)
(define cena-sol (colocar-figura sol 330 60 tela))

;; Posiciona a casa no centro-esquerda (X=130, Y=170) e usa (quotient largura-tela 2) como referência
(define cena-casa (colocar-figura casa-pronta 130 170 cena-sol))

;; Posiciona as árvores à direita
(define cena-arvore (colocar-figura arvore-grande 270 175 cena-casa))
(define paisagem-final (colocar-figura arvore-pequena 335 188 cena-arvore))

paisagem-final
```

---

## 📋 3. Roteiro Prático Passo a Passo
- Passo 1: Construa os componentes básicos (parede, telhado, porta e função `criar-arvore`) usando `define`.
- Passo 2: Crie o cenário com `(define tela (desenhar-cenario 400 250 "azul-ceu"))`.
- Passo 3: Coloque o Sol com `(colocar-figura sol 330 60 tela)`.
- Passo 4: Valide a figura com `and`, `not` e `check-expect`.
- Passo 5: Execute com **Ctrl+R** e admire sua tela panorâmica digital!

---

## 💡 Dica ao Mediador
Explique que o ponto (0, 0) fica no canto superior esquerdo da tela: aumentar X move para a direita; aumentar Y move para baixo. Essa compreensão de plano cartesiano é uma ponte direta para a matemática do Ensino Fundamental e Médio.
