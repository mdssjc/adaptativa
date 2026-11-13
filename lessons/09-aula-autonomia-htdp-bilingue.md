# Aula 09: Transição Bilíngue e Autonomia Plena HtDP
;; @aula: 9
;; @nivel: 3
;; @titulo: Transição Bilíngue e Autonomia Plena HtDP

## 🎯 Objetivo Pedagógico
Capacitar o aprendiz a transitar com segurança entre os comandos em Português e a sintaxe internacional oficial do How to Design Programs (HtDP), dominando coleções, textos e cenários.

---

## 📖 1. Motivação e Contexto Didático
Parabéns pela sua jornada! Você atingiu a maturidade computacional. Agora você tem o poder de programar na língua materna e também nos termos em inglês adotados em universidades do mundo inteiro!

---

## 🛠️ 2. Tabela de Equivalência Bilíngue

| Conceito | Português | Inglês HtDP Oficial (Níveis 2 e 3) |
| :--- | :--- | :--- |
| **Definições** | `(definir ...)` / `(defina ... como ...)` | `(define ...)` *(Nível 2)* |
| **Condicionais** | `(se condicao sim nao)` | `(if condicao sim nao)` *(Nível 2)* |
| **Múltiplos Ramos** | `(escolha [...])` | `(cond [...])` *(Nível 2)* |
| **Testes** | `(verificar-resultado ...)` | `(check-expect ...)` *(Nível 2)* |
| **Lógica Booleana** | `(e ...)` / `(ou ...)` / `(nao ...)` | `(and ...)` / `(or ...)` / `(not ...)` *(Nível 3)* |
| **Matemática** | `(quadrado n)` / `(potencia b e)` / `(quociente a b)` | `(sqr n)` / `(expt b e)` / `(quotient a b)` *(Nível 3)* |
| **Textos** | `(juntar-texto ...)` | `(string-append ...)` |
| | `(tamanho-texto ...)` | `(string-length ...)` |
| **Listas/Coleções** | `(lista 1 2 3)` | `(list 1 2 3)` |
| | `(primeiro lst)` | `(first lst)` |
| | `(resto lst)` | `(rest lst)` |
| | `(vazia? lst)` | `(empty? lst)` |

---

### a) Definindo funções em inglês HtDP
```racket
(define VELOCIDADE-PADRAO 10)

(define (calcular-distancia tempo velocidade)
  (* tempo velocidade))

(mostrar (juntar-texto "Distância percorrida: " (calcular-distancia 5 VELOCIDADE-PADRAO) " km"))
```

### b) Múltiplos ramos com 'cond', coleções e recursão
```racket
(define (classificar-esforco bpm)
  (cond
    [(< bpm 100) "Descanso ou aquecimento leve"]
    [(<= bpm 130) "Zona aeróbica ideal para saúde cardiovascular"]
    [else "Esforço moderado/intenso: consulte orientação profissional"]))

(define historico-bpm (list 75 110 125 140))

(define (somar-medicoes lista-bpm)
  (cond
    [(empty? lista-bpm) 0]
    [else (+ (first lista-bpm) (somar-medicoes (rest lista-bpm)))]))

(mostrar (juntar-texto "Primeira medição: " (first historico-bpm) " bpm"))
(mostrar (juntar-texto "Classificação: " (classificar-esforco (first historico-bpm))))
(mostrar (juntar-texto "Soma das medições: " (somar-medicoes historico-bpm) " bpm"))
```

### c) Lógica booleana ('and', 'or', 'not') e matemática ('sqr', 'expt', 'quotient') do Nível 3
```racket
(define (zona-aerobica? bpm)
  (and (>= bpm 100)
       (not (> bpm 130))))

(define (alerta-bpm? bpm)
  (or (< bpm 50)
      (> bpm 160)))

(define (media-inteira soma qtd)
  (quotient soma qtd))

(define (pontuacao-energia nivel)
  (+ (sqr nivel) (expt 2 nivel)))
```

### d) Testes com sintaxe oficial check-expect
```racket
(check-expect (calcular-distancia 3 10) 30)
(check-expect (classificar-esforco 85) "Descanso ou aquecimento leve")
(check-expect (somar-medicoes historico-bpm) 450)
(check-expect (somar-medicoes empty) 0)
(check-expect (zona-aerobica? 115) verdadeiro)
(check-expect (alerta-bpm? 45) verdadeiro)
(check-expect (media-inteira 450 4) 112)
(check-expect (pontuacao-energia 3) 17)
```

---

## 📋 3. Roteiro Prático Passo a Passo
- Passo 1: Experimente reescrever uma função anterior usando `(define ...)`.
- Passo 2: Crie uma função de classificação com `(cond [...])`.
- Passo 3: Adicione um `(check-expect ...)` para validar sua função.
- Passo 4: Crie uma lista com `(list ...)` ou `(lista ...)` e acesse elementos com `first` e `rest`.
- Passo 5: Execute com **Ctrl+R** e celebre sua autonomia plena!

---

## 💡 Dica ao Mediador
Mostre aos aprendizes que aprender lógica em português facilitou enormemente a compreensão dos conceitos, tornando os termos em inglês naturais e desprovidos de medo.
