# Aula 06: Geometria e Arte com a Tartaruga (Turtle Graphics)
;; @aula: 6
;; @nivel: 2
;; @titulo: Geometria e Arte com a Tartaruga (Turtle Graphics)

## 🎯 Objetivo Pedagógico
Compreender o pensamento geométrico e algorítmico através da metáfora da Tartaruga (*Turtle Graphics*). O aluno aprende a dar ordens de movimento no espaço, utilizando laços de repetição para criar polígonos, estrelas e mandalas.

---

## 📖 1. Motivação e Contexto Didático
A "Geometria da Tartaruga" foi criada pelo educador Seymour Papert para ensinar matemática e lógica de forma concreta: imagine uma tartaruguinha segurando uma caneta que caminha sobre o chão ou papel conforme as suas instruções. Quando ela anda, ela deixa um rastro colorido!

---

## 🛠️ 2. Conceitos e Comandos Principais

### a) Abrindo a janela da Tartaruga e ajustando a velocidade
Para iniciar o ambiente visual da tartaruga e acompanhar o desenho acontecendo passo a passo:
```racket
(iniciar-tartaruga)
(velocidade-tartaruga 6) ; De 1 (devagar) a 10 (rápido); 0 desenha na hora
```

### b) Movimento para Frente e para Trás
A tartaruga anda na direção em que o seu bico está apontando:
```racket
(avancar 100) ; Anda 100 passos para frente desenhando
(recuar 50)   ; Anda 50 passos para trás
```

### c) Girando a Tartaruga (Ângulos em Graus)
Você pode girar a tartaruga para a direita ou esquerda sem sair do lugar:
```racket
(girar-direita 90)  ; Vira 90 graus para a direita
(girar-esquerda 45) ; Vira 45 graus para a esquerda
```

### d) Cores e Espessura do Traço
Personalize o desenho com as cores em português e a espessura da caneta:
```racket
(mudar-cor "azul")
(mudar-espessura 4)
```

### e) Desenhando Formas com 'repetir'
Combinar `repetir` com a tartaruga é a maneira mais divertida de desenhar figuras geométricas:

* **Um Quadrado (4 lados e 4 giros de 90°):**
```racket
(repetir 4 vezes
  (avancar 100)
  (girar-direita 90))
```

* **Um Triângulo Equilátero (3 lados e 3 giros de 120°):**
```racket
(repetir 3 vezes
  (avancar 120)
  (girar-esquerda 120))
```

* **Uma Estrela Dourada (5 pontas com giros de 144°):**
```racket
(mudar-cor "dourado")
(mudar-espessura 3)
(repetir 5 vezes
  (avancar 150)
  (girar-direita 144))
```

### f) Reconhecendo padrões: transição de 'definir'/'se'/'verificar-resultado' para 'define'/'if'/'check-expect'
Em vez de repetir código para cada forma, podemos criar uma **abstração** usando a forma em português ou a forma HtDP habilitada no Nível 2:
```racket
;; Em português:
(definir (angulo-poligono-pt lados)
  (se (maior? lados 0)
      (dividir 360 lados)
      0))

;; Equivalente em HtDP (Nível 2):
(define (angulo-poligono lados)
  (if (maior? lados 0)
      (dividir 360 lados)
      0))

(verificar-resultado (angulo-poligono-pt 4) 90)
(check-expect (angulo-poligono 4) 90)

(define (poligono lados tamanho)
  (repetir lados vezes
    (avancar tamanho)
    (girar-direita (angulo-poligono lados))))

(poligono 4 100) ; Quadrado
(poligono 6 60)  ; Hexágono
```

### g) Levantando a Caneta (Andar sem riscar)
Quando quiser mover a tartaruga para outro ponto da tela sem desenhar:
```racket
(levantar-caneta)
(avancar 200)
(abaixar-caneta)
```

---

## 📋 3. Roteiro Prático Passo a Passo
- **Passo 1:** Abra a tartaruga com `(iniciar-tartaruga)`.
- **Passo 2:** Escolha a cor preferida com `(mudar-cor "verde")` e `(mudar-espessura 3)`.
- **Passo 3:** Desenhe uma cruz ou quadrado usando `avancar` e `girar-direita`.
- **Passo 4:** Use `(repetir 8 vezes ...)` girando 45° a cada passo para desenhar um octógono regular!

---

## 💡 Dica para o Mediador
Incentive o idoso a se levantar ou apontar com as mãos para onde a tartaruga está virando. Essa "geometria corporal" fortalece o raciocínio espacial, a lateralidade (direita/esquerda) e torna o aprendizado imersivo e prazeroso!
