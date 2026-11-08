# Aula 03: Funções Reutilizáveis, Matemática e Textos
;; @aula: 3
;; @nivel: 1
;; @titulo: Funções Reutilizáveis, Matemática e Textos

## 🎯 Objetivo Pedagógico
Consolidar o conceito de abstração por meio de funções com múltiplos parâmetros, praticar as operações matemáticas em português e dominar conversões básicas entre números e textos.

---

## 📖 1. Motivação e Contexto Didático
Quando cozinhamos uma receita de bolo para 4 pessoas e queremos prepará-la para 8 ou 12 convidados, não inventamos uma receita nova: apenas ajustamos as quantidades! Na programação, **funções com parâmetros** funcionam exatamente assim: você escreve a fórmula uma vez e a reutiliza com valores diferentes.

---

## 🛠️ 2. Conceitos e Comandos Principais

### a) Operações matemáticas em Português
Além de `somar`, a linguagem oferece comandos diretos para as quatro operações e arredondamento:
```racket
(subtrair 100 35)     ; 65
(multiplicar 6 4)     ; 24
(dividir 90 3)        ; 30
(arredondar 7.8)      ; 8
(maximo 12 45 28)     ; 45
(minimo 12 45 28)     ; 12
```

### b) Criando receitas com mais de um ingrediente (parâmetros)
Podemos ensinar uma função a receber vários valores de entrada:
```racket
(definir (ajustar-receita gramas-base porcoes-originais porcoes-desejadas)
  (arredondar (dividir (multiplicar gramas-base porcoes-desejadas) porcoes-originais)))

(mostrar (juntar-texto "Farinha para 10 pessoas: " (ajustar-receita 240 6 10) "g"))
```

### c) Potências simples e raízes
Para cálculos de medidas e áreas:
```racket
(quadrado 5)          ; 25
(raiz-quadrada 81)    ; 9
```

### d) Transformando e convertendo textos
Podemos padronizar textos e converter números em palavras (ou palavras em números):
```racket
(mostrar (texto-minusculo "BOM DIA A TODOS!"))
(mostrar (juntar-texto "Número convertido: " (numero->texto 42)))
(mostrar (somar (texto->numero "15") 10)) ; 25
```

---

## 📋 3. Roteiro Prático Passo a Passo
- Passo 1: Crie uma função `(definir (dobrar-ingrediente quantidade) (multiplicar quantidade 2))`.
- Passo 2: Teste a função com `250` gramas de farinha e exiba o resultado com `mostrar` e `juntar-texto`.
- Passo 3: Experimente usar `maximo` e `minimo` para comparar três preços de mercado.
- Passo 4: Converta um texto numérico com `texto->numero` e some com outro valor.
- Passo 5: Clique em **Executar (Ctrl+R)** e confira os resultados no console.

---

## 💡 Dica ao Mediador
Peça aos participantes que escolham uma receita culinária querida da família e transformem o cálculo das proporções em uma função. Ver o computador "adaptando" a receita para mais convidados torna a ideia de parâmetro e abstração imediatamente compreensível.
