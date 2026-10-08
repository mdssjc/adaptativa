#lang racket/base

(require (for-syntax racket/base syntax/parse)
         (prefix-in bsl: lang/htdp-beginner)
         racket/string
         (only-in racket/gui/base get-text-from-user message-box)
         "../pedagogy/syntax-macros.rkt"
         "../tracker/state.rkt")

(provide
 aluno
 definir
 se
 escolha
 verificar-resultado
 (rename-out
  [definir-htdp define]
  [se-htdp if]
  [escolha-htdp cond]
  [verificar-resultado-htdp check-expect]
  [bsl:else else]
  [and-htdp and]
  [or-htdp or]
  [not-htdp not]
  [sqr-htdp sqr]
  [expt-htdp expt]
  [quotient-htdp quotient])
 (rename-out
  [bsl:define-struct definir-registro]
  [bsl:define-struct define-struct]
  [bsl:else senao]
  [bsl:check-error verificar-erro]
  [bsl:check-within verificar-aproximado])
 defina
 mostrar
 repetir
 igual?
 diferente?
 maior?
 menor?
 maior-ou-igual?
 menor-ou-igual?
 e
 ou
 nao
 e-par?
 e-impar?
 e-positivo?
 e-negativo?
 e-zero?
 sortear-numero
 raiz-quadrada
 arredondar
 resto-divisao
 somar
 subtrair
 multiplicar
 dividir
 absoluto
 maximo
 minimo
 quadrado
 quociente
 potencia
 verdadeiro
 falso
 juntar-texto
 tamanho-texto
 texto->numero
 numero->texto
 texto-maiusculo
 texto-minusculo
 pedir-texto
 pedir-numero
 ler-linha
 ler-texto
 ler-numero
 esperar
 lista
 primeiro
 resto
 vazia?
 tamanho-lista
 juntar-listas
 inverter-lista)

(define-syntax (defina stx)
  (syntax-parse stx
    [(_ var-name:id (~datum como) val:expr)
     #'(definir var-name val)]

    [(_ var-name:id val:expr)
     (raise-syntax-error
      'defina
      "💡 Faltou a palavrinha 'como'! O formato amigável é: (defina <nome> como <valor>). Exemplo: (defina idade como 68)"
      stx)]

    [(_ var-name:id)
     (raise-syntax-error
      'defina
      "💡 Valor ausente! Você indicou o nome da variável, mas esqueceu de fornecer o valor. Exemplo: (defina saldo como 100)"
      stx)]

    [(_ val:expr (~datum como) var-name:id)
     (raise-syntax-error
      'defina
      "💡 Posição invertida! O nome da variável deve vir antes do 'como' e o valor depois. Exemplo: (defina cidade como \"São Paulo\")"
      stx)]

    [incorrect-form
     (raise-syntax-error
      'defina
      "💡 Estrutura de 'defina' não reconhecida. Use o formato: (defina <nome> como <valor>). Exemplo: (defina nome como \"Maria\")"
      #'incorrect-form)]))

(define-syntax (mostrar stx)
  (syntax-parse stx
    [(_ expr:expr ...+)
     #'(begin
         (void (begin (displayln expr) ...)))]
    [(_)
     (raise-syntax-error
      'mostrar
      "💡 Nada para exibir! O comando 'mostrar' precisa de pelo menos uma informação para imprimir na tela. Exemplo: (mostrar \"Olá!\")"
      stx)]))

(define-syntax (repetir stx)
  (syntax-parse stx
    [(_ n:expr (~datum vezes) body:expr ...+)
     #'(let ([limit n])
         (let loop ([counter 1])
           (when (<= counter limit)
             body ...
             (loop (+ counter 1)))))]

    [(_ n:expr (~datum vezes))
     (raise-syntax-error
      'repetir
      "💡 O que deve ser repetido? Você informou a quantidade, mas não colocou nenhuma instrução dentro do bloco. Exemplo: (repetir 3 vezes (mostrar \"Olá!\"))"
      stx)]

    [(_ n:expr body:expr ...+)
     (raise-syntax-error
      'repetir
      "💡 Faltou a palavrinha 'vezes'! O formato é: (repetir <número> vezes <instruções>...). Exemplo: (repetir 4 vezes (mostrar \"Oi\"))"
      stx)]

    [incorrect-form
     (raise-syntax-error
      'repetir
      "💡 Estrutura de 'repetir' incorreta. Use: (repetir <número> vezes <instrução>...). Exemplo: (repetir 3 vezes (mostrar \"Olá\"))"
      #'incorrect-form)]))

(define (igual? a b) (equal? a b))
(define (diferente? a b) (not (equal? a b)))
(define (maior? a b) (> a b))
(define (menor? a b) (< a b))
(define (maior-ou-igual? a b) (>= a b))
(define (menor-ou-igual? a b) (<= a b))

(define-syntax (e stx)
  (syntax-parse stx
    [(_ a:expr b:expr ...)
     #'(bsl:and a b ...)]))

(define-syntax (ou stx)
  (syntax-parse stx
    [(_ a:expr b:expr ...)
     #'(bsl:or a b ...)]))

(define (nao a) (not a))

(define (e-par? n) (even? n))
(define (e-impar? n) (odd? n))
(define (e-positivo? n) (positive? n))
(define (e-negativo? n) (negative? n))
(define (e-zero? n) (zero? n))

(define (sortear-numero min-val max-val)
  (+ min-val (random (+ 1 (- max-val min-val)))))

(define (raiz-quadrada n) (sqrt n))
(define (arredondar n) (round n))
(define (resto-divisao a b) (remainder a b))
(define somar +)
(define subtrair -)
(define multiplicar *)
(define dividir /)
(define absoluto abs)
(define maximo max)
(define minimo min)
(define (quadrado x) (* x x))
(define quociente quotient)
(define potencia expt)
(define verdadeiro #true)
(define falso #false)

(define (juntar-texto . parts)
  (apply string-append (map (lambda (p) (format "~a" p)) parts)))

(define (tamanho-texto txt)
  (string-length (format "~a" txt)))

(define (texto->numero txt)
  (string->number (string-trim (format "~a" txt))))

(define (numero->texto num)
  (number->string num))

(define (texto-maiusculo txt)
  (string-upcase (format "~a" txt)))

(define (texto-minusculo txt)
  (string-downcase (format "~a" txt)))

(define (pedir-texto [prompt-msg "Digite um texto:"] [window-title "Entrada de Texto"])
  (with-handlers ([exn:fail? (lambda (e) "")])
    (or (get-text-from-user window-title prompt-msg) "")))

(define (pedir-numero [prompt-msg "Digite um número:"] [window-title "Entrada Numérica"])
  (with-handlers ([exn:fail? (lambda (e) 0)])
    (let loop ()
      (define response (get-text-from-user window-title prompt-msg))
      (if (not response)
          0
          (let ([num (string->number (string-trim response))])
            (if num
                num
                (begin
                  (message-box "Aviso" "Por favor, digite um número válido!" #f '(ok caution))
                  (loop))))))))

(define (ler-linha [prompt-msg #f])
  (when (and (string? prompt-msg) (non-empty-string? prompt-msg))
    (display prompt-msg)
    (flush-output))
  (define line (read-line))
  (if (eof-object? line) "" (string-trim line "\r")))

(define ler-texto ler-linha)

(define (ler-numero [prompt-msg #f])
  (let loop ()
    (when (and (string? prompt-msg) (non-empty-string? prompt-msg))
      (display prompt-msg)
      (flush-output))
    (define line (read-line))
    (if (eof-object? line)
        0
        (let ([clean (string-trim (string-trim line "\r"))])
          (define num (string->number clean))
          (if num
              num
              (begin
                (displayln "Por favor, digite um número válido!")
                (loop)))))))

(define (esperar seconds)
  (sleep seconds))

(define (lista . items)
  items)

(define (primeiro lst)
  (if (pair? lst)
      (car lst)
      (error 'primeiro "A lista está vazia! Não é possível obter o primeiro elemento.")))

(define (resto lst)
  (if (pair? lst)
      (cdr lst)
      (error 'resto "A lista está vazia! Não é possível obter o resto.")))

(define (vazia? lst)
  (null? lst))

(define (tamanho-lista lst)
  (if (list? lst)
      (length lst)
      0))

(define (juntar-listas . lists)
  (apply append lists))

(define (inverter-lista lst)
  (reverse lst))
