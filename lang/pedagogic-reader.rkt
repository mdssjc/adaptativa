#lang racket/base
(require syntax/module-reader
         racket/port
         "../pedagogy/feedback.rkt")

(install-pedagogic-error-handler!)

(define (translate-read-message msg)
  (cond
    [(or (regexp-match? #px"expected a closing [`'\"]?\"" msg)
         (regexp-match? #px"expected a `\"` to close" msg))
     "💡 Texto não fechado: Você abriu aspas duplas (\") para um texto mas esqueceu de fechá-las com outra aspa dupla (\")."]
    [(or (regexp-match? #px"expected a closing [`'\"]?'" msg)
         (regexp-match? #px"expected a `'` to close" msg))
     "💡 Caractere não fechado: Você abriu aspas simples (') mas esqueceu de fechá-las."]
    [(or (regexp-match? #px"expected a `\\)` to close `\\(`" msg)
         (regexp-match? #px"expected a closing [`'\"]?\\)" msg))
     "💡 Parêntese não fechado: Você abriu um parêntese '(' mas esqueceu de fechar com ')' antes do fim da instrução."]
    [(or (regexp-match? #px"expected a `\\]` to close `\\[`" msg)
         (regexp-match? #px"expected a closing [`'\"]?\\]" msg))
     "💡 Colchete não fechado: Você abriu um colchete '[' mas esqueceu de fechar com ']'."]
    [(or (regexp-match? #px"expected a `\\}` to close `\\{`" msg)
         (regexp-match? #px"expected a closing [`'\"]?\\}" msg))
     "💡 Chave não fechada: Você abriu uma chave '{' mas esqueceu de fechar com '}'."]
    [(regexp-match? #px"unexpected [`'\"]?\\)" msg)
     "💡 Parêntese sobrando: Encontrado um parêntese de fechamento ')' que não possui um '(' correspondente."]
    [(regexp-match? #px"unexpected [`'\"]?\\]" msg)
     "💡 Colchete sobrando: Encontrado um colchete de fechamento ']' que não possui um '[' correspondente."]
    [(regexp-match? #px"unexpected [`'\"]?\\}" msg)
     "💡 Chave sobrando: Encontrada uma chave de fechamento '}' que não possui uma '{' correspondente."]
    [(regexp-match? #px"illegal use of `\\.`" msg)
     "💡 Ponto final fora de lugar: Em programação, o ponto '.' só deve ser usado dentro de números decimais (como 3.14) ou dentro de textos entre aspas. Não use ponto final para encerrar linhas ou separar instruções."]
    [(regexp-match? #px"bad syntax: #|unknown character name" msg)
     "💡 Caractere especial desconhecido: O símbolo '#' é reservado para valores como #true e #false. Para escrever textos com '#', coloque entre aspas (ex: \"#1\")."]
    [(regexp-match? #px"#lang not at beginning of file" msg)
     "💡 Cabeçalho fora do início: A instrução '#lang adaptativa' deve ser obrigatoriamente a primeira linha do arquivo."]
    [else msg]))

(define (adaptativa-read in)
  (with-handlers ([exn:fail:read:eof?
                   (lambda (e)
                     (raise (make-exn:fail:read:eof
                             (translate-read-message (exn-message e))
                             (current-continuation-marks)
                             (exn:fail:read-srclocs e))))]
                  [exn:fail:read?
                   (lambda (e)
                     (raise (make-exn:fail:read
                             (translate-read-message (exn-message e))
                             (current-continuation-marks)
                             (exn:fail:read-srclocs e))))])
    (read in)))

(define (adaptativa-read-syntax src in)
  (with-handlers ([exn:fail:read:eof?
                   (lambda (e)
                     (raise (make-exn:fail:read:eof
                             (translate-read-message (exn-message e))
                             (current-continuation-marks)
                             (exn:fail:read-srclocs e))))]
                  [exn:fail:read?
                   (lambda (e)
                     (raise (make-exn:fail:read
                             (translate-read-message (exn-message e))
                             (current-continuation-marks)
                             (exn:fail:read-srclocs e))))])
    (read-syntax src in)))

(provide adaptativa-read
         adaptativa-read-syntax
         translate-read-message)
