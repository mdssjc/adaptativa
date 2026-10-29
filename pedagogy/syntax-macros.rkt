#lang racket/base

(require (for-syntax racket/base
                     syntax/parse
                     "feedback.rkt")
         (prefix-in bsl: lang/htdp-beginner)
         "../tracker/state.rkt"
         "../tracker/config.rkt")

(provide definir
         se
         escolha
         verificar-resultado
         definir-htdp
         se-htdp
         escolha-htdp
         verificar-resultado-htdp
         and-htdp
         or-htdp
         not-htdp
         sqr-htdp
         expt-htdp
         quotient-htdp
         check-syntactic-level!)

(define (check-syntactic-level! required-level eng-name pt-name [src-str #f])
  (define effective-level
    (if (and (string? src-str) (system-or-test-path? src-str))
        3
        (get-student-syntactic-level)))
  (when (< effective-level required-level)
    (define config (load-teacher-config))
    (define target
      (if (= required-level 2)
          (hash-ref config 'pontos_nivel_2 4)
          (hash-ref config 'pontos_nivel_3 8)))
    (define pts (get-student-points #f))
    (define level-desc
      (if (= required-level 2)
          "No Nível 1 (Iniciante)"
          "Nos Níveis 1 e 2"))
    (define unlock-desc
      (if (= required-level 2)
          "para desbloquear a sintaxe oficial do HtDP"
          "para desbloquear a sintaxe oficial do HtDP no Nível 3"))
    (error eng-name
           (format "💡 Atenção: Você utilizou a forma inglesa '~a'.~n~a, usamos '~a' em português!~nVocê tem ~a/~a pontos ~a."
                   eng-name level-desc pt-name pts target unlock-desc))))

(begin-for-syntax
  (define (syntax-source-string stx)
    (define src (syntax-source stx))
    (cond
      [(path? src) (path->string src)]
      [(string? src) src]
      [else #f]))

  (define (raise-pedagogic-syntax-error who category base-hint stx)
    (define level (get-adaptive-level category))
    (record-error-attempt! category)
    (define msg (generate-didactic-message category level base-hint))
    (raise-syntax-error who msg stx)))

(define-syntax (definir stx)
  (syntax-parse stx
    [(_ (name:id param:id ...+) body:expr)
     #'(bsl:define (name param ...) body)]

    [(_ name:id val:expr)
     #'(bsl:define name val)]

    [(_ name:id)
     (raise-pedagogic-syntax-error
      'definir 'definicao-vazia
      "Você declarou o nome, mas esqueceu de fornecer o valor inicial ou o corpo."
      stx)]

    [(_ (name:id param:id ...))
     (raise-pedagogic-syntax-error
      'definir 'definicao-vazia
      "Você declarou o cabeçalho da função, mas esqueceu de escrever o corpo da instrução."
      stx)]

    [(_ (name:id param:id ...+) body1:expr body2:expr ...+)
     (raise-pedagogic-syntax-error
      'definir 'corpo-multiplo
      "No corpo de uma função, coloque apenas uma única instrução com o resultado. Se você tentou usar 'defina' dentro da função, lembre-se de que variáveis devem ser criadas fora (no início do arquivo)."
      stx)]

    [(_ (name:id param ...) body:expr ...+)
     #:when (for/or ([p (syntax->list #'(param ...))]) (not (identifier? p)))
     (raise-pedagogic-syntax-error
      'definir 'parametro-invalido
      "Os parâmetros da função devem ser nomes de variáveis (identificadores), não números ou valores fixos."
      stx)]

    [incorrect-form
     (raise-pedagogic-syntax-error
      'definir 'sintaxe-definir
      "Estrutura de 'definir' não reconhecida. Para variáveis use '(definir nome valor)' e para funções use '(definir (nome param) corpo)'."
      #'incorrect-form)]))

(define-syntax (definir-htdp stx)
  (syntax-parse stx
    [(_ (name:id param:id ...+) body:expr)
     #'(bsl:define (name param ...) body)]
    [(_ name:id val:expr)
     #'(bsl:define name val)]
    [(_ rest ...)
     #'(bsl:define rest ...)]))

(define-syntax (verificar-resultado-htdp stx)
  (syntax-parse stx
    [(_ expr:expr expected:expr)
     #'(bsl:check-expect expr expected)]
    [(_ rest ...)
     #'(bsl:check-expect rest ...)]))

(define-syntax (se stx)
  (syntax-parse stx
    [(_ condition:expr then-branch:expr else-branch:expr)
     #'(bsl:if condition then-branch else-branch)]

    [(_ condition:expr then-branch:expr)
     (raise-pedagogic-syntax-error
      'se 'se-incompleto
      "O comando 'se' precisa de dois caminhos: o que fazer quando a condição for verdadeira e o que fazer quando for falsa."
      stx)]

    [incorrect-form
     (raise-pedagogic-syntax-error
      'se 'se-incompleto
      "Estrutura de 'se' inválida. Use o formato: (se condicao entao senao)."
      #'incorrect-form)]))

(define-syntax (escolha stx)
  (syntax-parse stx
    [(_ [question:expr answer:expr] ...+)
     #'(bsl:cond [question answer] ...)]

    [(_)
     (raise-pedagogic-syntax-error
      'escolha 'escolha-invalida
      "O comando 'escolha' precisa de pelo menos uma alternativa entre colchetes [condicao resposta]."
      stx)]

    [incorrect-form
     (raise-pedagogic-syntax-error
      'escolha 'escolha-invalida
      "Formato de 'escolha' inválido. Certifique-se de envolver cada par em colchetes: [teste resposta]."
      #'incorrect-form)]))

(define-syntax (verificar-resultado stx)
  (syntax-parse stx
    [(_ expr:expr expected:expr)
     #'(bsl:check-expect expr expected)]

    [(_ expr:expr)
     (raise-pedagogic-syntax-error
      'verificar-resultado 'teste-incompleto
      "O teste precisa de dois itens: a instrução a testar e o resultado esperado."
      stx)]

    [incorrect-form
     (raise-pedagogic-syntax-error
      'verificar-resultado 'teste-incompleto
      "Formato de 'verificar-resultado' inválido. Use: (verificar-resultado (funcao args) esperado)."
      #'incorrect-form)]))

(define-syntax-rule (define-htdp-expr-macro name bsl-form req-level eng-sym pt-str)
  (define-syntax (name stx)
    (syntax-case stx ()
      [(_ rest (... ...))
       (let ([src-str (syntax-source-string stx)])
         #`(let ()
             (check-syntactic-level! req-level 'eng-sym pt-str '#,src-str)
             (bsl-form rest (... ...))))])))

(define-htdp-expr-macro se-htdp bsl:if 2 if "se")
(define-htdp-expr-macro escolha-htdp bsl:cond 2 cond "escolha")
(define-htdp-expr-macro and-htdp bsl:and 3 and "e")
(define-htdp-expr-macro or-htdp bsl:or 3 or "ou")
(define-htdp-expr-macro not-htdp bsl:not 3 not "nao")
(define-htdp-expr-macro sqr-htdp bsl:sqr 3 sqr "quadrado")
(define-htdp-expr-macro expt-htdp bsl:expt 3 expt "potencia")
(define-htdp-expr-macro quotient-htdp bsl:quotient 3 quotient "quociente")
