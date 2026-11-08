# Aula 02: Formas Geométricas, Cores e Abstração Visual
;; @aula: 2
;; @nivel: 1
;; @titulo: Formas Geométricas, Cores e Abstração Visual

## 🎯 Objetivo Pedagógico
Desenvolver o pensamento espacial e a abstração visual compondo figuras geométricas simples em pinturas digitais expressivas e compreendendo suas dimensões.

---

## 📖 1. Motivação e Contexto Didático
Programar não é apenas calcular números: é também desenhar, ilustrar e expressar criatividade visual através de blocos e formas geométricas coloridas!

---

## 🛠️ 2. Conceitos e Comandos Principais

### a) Desenhando formas básicas
Você pode criar círculos, retângulos, triângulos e estrelas com cores vivas em português:
```racket
(desenhar-circulo 30 "solido" "amarelo")
(desenhar-retangulo 100 40 "solido" "azul")
(desenhar-triangulo 60 "solido" "vermelho")
(desenhar-estrela 30 "solido" "dourado")
```

### b) Medindo dimensões com 'largura-figura' e 'altura-figura'
Podemos inspecionar o tamanho exato de qualquer desenho criado em pixels:
```racket
(defina estrela como (desenhar-estrela 35 "solido" "azul"))
(mostrar (juntar-texto "Largura da estrela: " (largura-figura estrela) " pixels"))
(mostrar (juntar-texto "Altura da estrela: " (altura-figura estrela) " pixels"))
```

### c) Compondo imagens no espaço
Podemos juntar várias formas usando os operadores espaciais:
```racket
(lado-a-lado (desenhar-circulo 20 "solido" "azul") (desenhar-circulo 20 "solido" "vermelho"))
(acima-de (desenhar-triangulo 40 "solido" "verde") (desenhar-quadrado 40 "solido" "marrom"))
(sobrepor (desenhar-circulo 15 "solido" "amarelo") (desenhar-circulo 30 "solido" "laranja"))
```

### d) Guardando suas criações em variáveis
Dê nomes às suas figuras para reutilizá-las:
```racket
(definir sol
  (desenhar-circulo 35 "solido" "amarelo"))

(definir gramado
  (desenhar-retangulo 200 40 "solido" "verde"))
```

---

## 📋 3. Roteiro Prático Passo a Passo
- Passo 1: Crie um círculo amarelo para representar o Sol brilhante.
- Passo 2: Crie um triângulo vermelho e um quadrado azul.
- Passo 3: Monte uma casinha usando `(acima-de triangulo quadrado)`.
- Passo 4: Combine a casinha com o Sol usando `(lado-a-lado casinha sol)`.
- Passo 5: Use `(largura-figura casinha)` para conferir a largura da sua construção.
- Passo 6: Clique em **Executar (Ctrl+R)** e admire sua pintura digital na tela!

---

## 💡 Dica ao Mediador
Incentive os aprendizes a criarem bandeiras, flores ou paisagens que lembrem suas cidades natais. O retorno visual imediato gera grande encantamento e motivação.
