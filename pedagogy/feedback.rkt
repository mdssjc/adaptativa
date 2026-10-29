#lang racket/base

(require racket/format
         "../tracker/state.rkt")

(provide get-adaptive-level
         record-error-attempt!
         generate-didactic-message
         get-practical-example
         get-htdp-model
         translate-runtime-message
         install-pedagogic-error-handler!
         running-in-drracket?
         should-record-pedagogic-event?)

(define (running-in-drracket?)
  (or (equal? (getenv "AMB_DRRACKET") "true")
      (equal? (getenv "PLTDRX") "true")
      (with-handlers ([exn:fail? (lambda (e) #f)])
        (regexp-match? #px"(?i:drracket)" (path->string (find-system-path 'exec-file))))))

(define (should-record-pedagogic-event?)
  (or (not (running-in-drracket?))
      (execution-authorized?)))

(define (translate-runtime-message msg [exn #f])
  (define student (get-current-student))
  (define-values (translated cat-sym)
    (cond
      [(regexp-match #px"^([^:]+): (?:this variable is not defined|undefined; cannot use before initialization)" msg)
       (let ([m (regexp-match #px"^([^:]+): (?:this variable is not defined|undefined; cannot use before initialization)" msg)])
         (values (format "💡 Nome desconhecido: O identificador '~a' não foi definido.\n   👉 Verifique se você digitou o nome corretamente ou se esqueceu de criá-lo com '(defina ~a como ...)'."
                         (cadr m) (cadr m))
                 'variavel-indefinida))]

      [(regexp-match? #px"/: division by zero" msg)
       (values "💡 Divisão por zero: Na matemática não é possível dividir nenhum número por 0.\n   👉 Verifique o segundo valor da divisão para garantir que ele seja diferente de zero."
               'divisao-por-zero)]

      [(or (regexp-match #px"^([^:]+): arity mismatch;[^\n]*\n?\\s*expected:\\s*(\\d+)[^\n]*\n?\\s*given:\\s*(\\d+)" msg)
           (regexp-match #px"^([^:]+): expects (\\d+) arguments?, given (\\d+)" msg))
       (let ([m (or (regexp-match #px"^([^:]+): arity mismatch;[^\n]*\n?\\s*expected:\\s*(\\d+)[^\n]*\n?\\s*given:\\s*(\\d+)" msg)
                    (regexp-match #px"^([^:]+): expects (\\d+) arguments?, given (\\d+)" msg))])
         (values (format "💡 Quantidade incorreta de valores: A instrução '~a' esperava receber ~a valor(es), mas recebeu ~a.\n   👉 Verifique os valores fornecidos entre parênteses para essa função."
                         (cadr m) (caddr m) (cadddr m))
                 'quantidade-argumentos))]

      [(regexp-match #px"([+\\-*/]|>|<|>=|<=): contract violation;[^\n]*expected: (?:number\\?|real\\?),[^\n]*given: ([^\n]+)" msg)
       (let ([m (regexp-match #px"([+\\-*/]|>|<|>=|<=): contract violation;[^\n]*expected: (?:number\\?|real\\?),[^\n]*given: ([^\n]+)" msg)])
         (values (format "💡 Tentativa de calcular com texto: A operação '~a' só funciona com números, mas recebeu ~a.\n   👉 Para juntar palavras use '(juntar-texto ...)'. Para somar quantidades, use números sem aspas."
                         (cadr m) (caddr m))
                 'operacao-invalida))]

      [(regexp-match #px"(?:string-length|string-upcase|string-downcase|string-append): contract violation;[^\n]*given: ([^\n]+)" msg)
       (let ([m (regexp-match #px"(?:string-length|string-upcase|string-downcase|string-append): contract violation;[^\n]*given: ([^\n]+)" msg)])
         (values (format "💡 Esperava um texto: Esta operação precisa de um texto entre aspas (\"), mas recebeu ~a.\n   👉 Se desejar converter o número para texto, use '(numero->texto ...)'."
                         (cadr m))
                 'tipo-invalido))]

      [(regexp-match #px"(?:first|rest|car|cdr): contract violation;[^\n]*expected: (?:pair\\?|list\\?),[^\n]*given: ([^\n]+)" msg)
       (let ([m (regexp-match #px"(?:first|rest|car|cdr): contract violation;[^\n]*expected: (?:pair\\?|list\\?),[^\n]*given: ([^\n]+)" msg)])
         (values (format "💡 Esperava uma lista: Esta operação precisa de uma lista criada com '(lista ...)', mas recebeu ~a.\n   👉 Crie a lista primeiro, por exemplo: (defina compras como (lista \"Maçã\" \"Banana\"))."
                         (cadr m))
                 'tipo-invalido))]

      [(or (regexp-match? #px"(?:first|rest): expects argument of type <non-empty list>" msg)
           (regexp-match? #px"(?:car|cdr): contract violation;[^\n]*given: '(?:\\(\\)|null)" msg))
       (values "💡 Lista vazia: Não é possível pegar itens de uma lista que não possui nenhum elemento.\n   👉 Antes de acessar itens, verifique se a lista tem elementos usando '(vazia? ...)'."
               'lista-vazia)]

      [(or (regexp-match? #px"sqrt: contract violation" msg)
           (regexp-match? #px"raiz-quadrada: contract violation" msg))
       (values "💡 Raiz quadrada inválida: Não é possível calcular a raiz quadrada real de um número negativo.\n   👉 Forneça um número maior ou igual a zero."
               'raiz-negativa)]

      [(regexp-match? #px"cond: all question results were false" msg)
       (values "💡 Nenhuma opção foi atendida: No comando 'escolha', nenhuma das alternativas resultou em verdadeiro e faltou uma resposta padrão.\n   👉 Adicione a opção '[senao <resultado>]' no final da sua 'escolha'."
               'escolha-invalida)]

      [(regexp-match #px"([^:\\s]+): this name was defined in the language or a required library and cannot be re-defined" msg)
       (let ([m (regexp-match #px"([^:\\s]+): this name was defined in the language or a required library and cannot be re-defined" msg)])
         (values (format "💡 Palavra reservada da linguagem: O nome '~a' já pertence aos comandos da linguagem ou a uma biblioteca e não pode ser redefinido.\n   👉 Escolha um nome diferente para a sua função ou variável (por exemplo: 'meu-~a' ou outro nome que descreva sua ação)."
                         (cadr m) (cadr m))
                 'palavra-reservada))]

      [(regexp-match #px"([^:\\s]+): this name was defined previously and cannot be re-defined" msg)
       (let ([m (regexp-match #px"([^:\\s]+): this name was defined previously and cannot be re-defined" msg)])
         (values (format "💡 Nome já definido anteriormente: O nome '~a' já foi criado antes neste mesmo programa e não pode ser redefinido.\n   👉 Verifique se você já definiu '~a' em outra linha. Para alterar ou usar outro valor, utilize um nome diferente."
                         (cadr m) (cadr m))
                 'nome-redefinido))]

      [else
       (values msg #f)]))

  (when (and cat-sym (should-record-pedagogic-event?))
    (with-handlers ([exn:fail? (lambda (e) (void))])
      (record-student-error! student cat-sym)))

  translated)

(define (install-pedagogic-error-handler!)
  (define orig-edh (error-display-handler))
  (error-display-handler
   (lambda (msg exn)
     (orig-edh (translate-runtime-message msg exn) exn))))

(define (get-adaptive-level category)
  (define student-id (get-current-student))
  (get-student-level student-id category))

(define (record-error-attempt! category)
  (when (should-record-pedagogic-event?)
    (define student-id (get-current-student))
    (record-student-error! student-id category)))

(define (generate-didactic-message category level base-hint)
  (case level
    [(1)
     (format "💡 Atenção: ~a~nO que você esperava que o computador fizesse nessa etapa?"
             base-hint)]
    [(2)
     (format "📘 Lembrete Prático:~n~a~nExemplo de uso correto:~n~a"
             base-hint
             (get-practical-example category))]
    [else
     (format "🛠️ Guia HtDP (Design Recipe):~n~a~nSiga o modelo estruturado:~n~a"
             base-hint
             (get-htdp-model category))]))

(define (get-practical-example category)
  (case category
    [(definicao-vazia sintaxe-definir)
     "  (definir gravidade 9.8)\n  (definir (dobro x) (* x 2))"]
    [(parametro-invalido)
     "  (definir (somar-um n) (+ n 1)) ; 'n' deve ser um nome, não um número"]
    [(corpo-multiplo)
     "  (definir (dobro x) (* x 2)) ; Apenas uma única instrução com o cálculo de retorno"]
    [(se-incompleto)
     "  (se (maior? idade 60) \"Sênior\" \"Adulto\") ; Precisa da condição, caso sim e caso não"]
    [(escolha-invalida)
     "  (escolha\n    [(igual? opcao 1) \"Início\"]\n    [senao \"Outro\"])"]
    [(teste-incompleto)
     "  (verificar-resultado (dobro 4) 8) ; Precisa da expressão e do resultado esperado"]
    [(palavra-reservada)
     "  (definir (calcular-total a b) (+ a b)) ; Use um nome próprio em vez de comandos do sistema"]
    [(nome-redefinido)
     "  (definir primeiro-valor 10)\n  (definir segundo-valor 20) ; Use nomes distintos para cada definição"]
    [else
     "  Consulte o mediador ou o Guia de Sintaxe para mais detalhes."]))

(define (get-htdp-model category)
  (case category
    [(definicao-vazia sintaxe-definir parametro-invalido)
     ";; 1. Assinatura: nome : Tipo -> Tipo\n;; 2. Propósito: O que a função faz\n;; 3. Cabeçalho: (definir (nome param ...) ...)\n;; 4. Testes: (verificar-resultado (nome ...) ...)"]
    [(se-incompleto escolha-invalida)
     ";; Decisão Condicional:\n;; Verifique se todas as alternativas possíveis possuem uma resposta definida."]
    [(palavra-reservada nome-redefinido)
     ";; Escolha de Nomes:\n;; Cada função e variável deve ter um nome único e diferente das palavras do sistema."]
    [else
     ";; Siga o Design Recipe: Assinatura -> Propósito -> Exemplos -> Template -> Código -> Testes"]))
