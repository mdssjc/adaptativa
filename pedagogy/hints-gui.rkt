#lang racket/base

(require racket/gui/base
         racket/class
         racket/file
         racket/path
         racket/string
         racket/format
         "../tracker/state.rkt"
         "../tracker/config.rkt"
         "custom-content.rkt")

(provide open-adaptive-hints-window
         extract-example-metadata
         load-available-examples
         get-suggested-index
         get-examples-directory
         read-example-code)

(define (get-examples-directory)
  (get-default-examples-dir))

(define (extract-example-metadata file-path filename [customized? #f])
  (define lines
    (with-handlers ([exn:fail? (lambda (e) '())])
      (file->lines file-path)))

  (define rx-level #px"(?i:^\\s*;+.*@?(?:nivel|nível)\\s*[:=]\\s*([0-9]+))")
  (define rx-lesson #px"(?i:^\\s*;+.*@?(?:licao|lição)\\s*[:=]\\s*([0-9]+))")
  (define rx-title #px"(?i:^\\s*;+.*@?(?:titulo|título)\\s*[:=]\\s*(.+))")

  (define level-found #f)
  (define lesson-found #f)
  (define title-found #f)

  (for ([l lines])
    (cond
      [(and (not level-found) (regexp-match rx-level l))
       => (lambda (m) (set! level-found (string->number (cadr m))))])
    (cond
      [(and (not lesson-found) (regexp-match rx-lesson l))
       => (lambda (m) (set! lesson-found (string->number (cadr m))))])
    (cond
      [(and (not title-found) (regexp-match rx-title l))
       => (lambda (m) (set! title-found (string-trim (cadr m))))]))

  (define level
    (or level-found
        (let ([m (regexp-match #px"(?i:level([0-9]+)|nivel([0-9]+))" filename)])
          (if m (string->number (or (cadr m) (caddr m))) 1))))

  (define lesson
    (or lesson-found
        (let ([m (regexp-match #px"^([0-9]+)" filename)])
          (if m (string->number (cadr m)) 0))))

  (define title
    (or title-found
        (let* ([without-ext (regexp-replace #px"\\.rkt$" filename "")]
               [without-num (regexp-replace #px"^[0-9]+-(?:level[0-9]+-|nivel[0-9]+-)?" without-ext "")]
               [words (string-split without-num "-")])
          (string-join (map string-titlecase words) " "))))

  (define icon
    (case level
      [(1) "🌱"]
      [(2) "🌿"]
      [(3) "🌟"]
      [else "📘"]))

  (define base-label
    (if (> lesson 0)
        (format "~a [Nível ~a] Lição ~a: ~a"
                icon
                level
                (~r lesson #:min-width 2 #:pad-string "0")
                title)
        (format "~a [Nível ~a] ~a"
                icon
                level
                title)))

  (define label
    (if customized?
        (format "~a ✏️ [Docente]" base-label)
        base-label))

  (hash 'arquivo filename
        'nivel level
        'licao lesson
        'titulo title
        'icone icon
        'label label
        'caminho file-path
        'customizado? customized?))

(define (load-available-examples [force-reload? #f])
  (define standard-dir (get-default-examples-dir))
  (define standard-items
    (if (directory-exists? standard-dir)
        (filter (lambda (p)
                  (and (path-has-extension? p #".rkt")
                       (file-exists? (build-path standard-dir p))))
                (directory-list standard-dir))
        '()))

  (define standard-examples
    (for/list ([p standard-items])
      (define fn (path->string p))
      (define full-path (build-path standard-dir p))
      (extract-example-metadata full-path fn #f)))

  (define custom-dir (get-custom-examples-dir))
  (define custom-items
    (if (directory-exists? custom-dir)
        (filter (lambda (p)
                  (and (path-has-extension? p #".rkt")
                       (file-exists? (build-path custom-dir p))))
                (directory-list custom-dir))
        '()))

  (define custom-examples
    (for/list ([p custom-items])
      (define fn (path->string p))
      (define full-path (build-path custom-dir p))
      (extract-example-metadata full-path fn #t)))

  (define all-examples (append standard-examples custom-examples))

  (sort all-examples
        (lambda (a b)
          (define n-a (hash-ref a 'nivel 1))
          (define n-b (hash-ref b 'nivel 1))
          (if (= n-a n-b)
              (let ([l-a (hash-ref a 'licao 0)]
                    [l-b (hash-ref b 'licao 0)])
                (if (= l-a l-b)
                    (string<? (hash-ref a 'arquivo "") (hash-ref b 'arquivo ""))
                    (< l-a l-b)))
              (< n-a n-b)))))

(define (get-suggested-index student-level examples-list)
  (define idx
    (for/first ([(ex i) (in-indexed examples-list)]
                #:when (>= (hash-ref ex 'nivel 1) student-level))
      i))
  (or idx 0))

(define (read-example-code filename)
  (define custom-path (build-path (get-custom-examples-dir) filename))
  (define target-path
    (if (file-exists? custom-path)
        custom-path
        (build-path (get-default-examples-dir) filename)))
  (if (file-exists? target-path)
      (file->string target-path)
      ";; Exemplo não encontrado."))

(define (open-adaptive-hints-window [parent-window #f])
  (define current-student (get-current-student))
  (define student-level (get-student-syntactic-level current-student))
  (define student-points (get-student-points current-student))

  (define level-desc
    (case student-level
      [(1) "🌱 Nível 1: Fundamentos & Expressão em Português"]
      [(2) "🌿 Nível 2: Tomada de Decisão Lógica, Testes & Repetição"]
      [(3) "🌟 Nível 3: Abstração Visual Avançada & HtDP Oficial"]
      [else "Nível Didático Adaptativo"]))

  (define examples (load-available-examples #t))
  (define choices (map (lambda (e) (hash-ref e 'label)) examples))

  (define initial-idx
    (if (pair? examples)
        (get-suggested-index student-level examples)
        0))

  (define dlg
    (new dialog%
         [label "💡 Dicas Adaptativas e Biblioteca de Exemplos"]
         [parent parent-window]
         [width 850]
         [height 650]
         [style '(resize-border close-button)]))

  (define main-panel
    (new vertical-panel%
         [parent dlg]
         [border 12]
         [spacing 10]))

  (define header-panel
    (new horizontal-panel%
         [parent main-panel]
         [alignment '(left center)]
         [stretchable-height #f]))

  (new message%
       [parent header-panel]
       [label (format "🎓 Aprendiz: ~a   |   ⭐ Pontuação: ~a pontos   |   ~a"
                      current-student student-points level-desc)])

  (define hint-group
    (new group-box-panel%
         [parent main-panel]
         [label "🎯 Orientação Didática para o seu Nível"]
         [alignment '(left top)]
         [stretchable-height #f]))

  (define hint-items
    (case student-level
      [(1)
       (list
        (cons 'focus "🎯 Foco Pedagógico: Primeiros Passos & Expressão em Português")
        (cons 'item "• Memória e Variáveis: Guarde valores usando (defina nome como valor) ou (definir nome valor).")
        (cons 'item "• Formas Visuais: Crie desenhos com (desenhar-circulo raio cor) e (desenhar-quadrado lado cor).")
        (cons 'item "• Diálogo e Leitura: Use (mostrar ...), janelas com (pedir-texto ...) ou terminal com (ler-linha ...).")
        (cons 'item "• Primeiras Funções: Crie receitas de cálculo com (definir (nome-da-funcao param) corpo).")
        (cons 'tip "💡 Dica ao Aprendiz: Escolha um exemplo na biblioteca abaixo e clique em 'Copiar Código' para testar no DrRacket!"))]
      [(2)
       (list
        (cons 'focus "🎯 Foco Pedagógico: Tomada de Decisão Lógica, Repetição & Testes Automatizados")
        (cons 'item "• Tomada de Decisão: Use (se condicao entao senao) para 2 vias ou (escolha ...) para múltiplos casos.")
        (cons 'item "• Repetição sem Esforço: Automatize tarefas repetitivas usando (repetir N vezes instrucao).")
        (cons 'item "• Comparações: Avalie dados com (igual? a b), (maior? a b), (menor? a b), (par? n) e (impar? n).")
        (cons 'item "• Garantia de Qualidade: Valide seu raciocínio com (verificar-resultado (funcao arg) valor-esperado).")
        (cons 'tip "💡 Dica ao Aprendiz: Comece sempre pelo caso principal da função antes de tratar condições especiais!"))]
      [else
       (list
        (cons 'focus "🎯 Foco Pedagógico: Transição Completa para o HtDP Oficial & Autonomia Bilíngue")
        (cons 'item "• Sintaxe Padrão HtDP: O ambiente aceita formas oficiais em inglês: define, if, cond e check-expect.")
        (cons 'item "• Receita de Design (HtDP): 1. Assinatura e Propósito -> 2. Cabeçalho -> 3. Testes -> 4. Implementação.")
        (cons 'item "• Abstração e Composição: Combine imagens com sobrepor, ao-lado, acima e animações interativas.")
        (cons 'item "• Autonomia e Monitoria: Você está apto a criar projetos autorais e apoiar colegas na Casa do Idoso!")
        (cons 'tip "💡 Dica ao Aprendiz: Compare os exemplos em português com a sintaxe oficial em inglês para consolidar o domínio!"))]))

  (define hint-panel
    (new vertical-panel%
         [parent hint-group]
         [alignment '(left top)]
         [spacing 3]
         [stretchable-width #t]))

  (for ([entry hint-items])
    (define kind (car entry))
    (define txt (cdr entry))
    (case kind
      [(focus)
       (new message%
            [parent hint-panel]
            [label txt]
            [auto-resize #t]
            [font (make-object font% 10 'default 'normal 'bold)])]
      [(tip)
       (new message%
            [parent hint-panel]
            [label txt]
            [auto-resize #t]
            [font (make-object font% 9 'default 'italic 'normal)])]
      [else
       (new message%
            [parent hint-panel]
            [label txt]
            [auto-resize #t]
            [font (make-object font% 9 'default 'normal 'normal)])]))

  (define selector-group
    (new group-box-panel%
         [parent main-panel]
         [label "📚 Biblioteca de Exemplos Práticos"]
         [stretchable-height #t]))

  (define choice-panel
    (new horizontal-panel%
         [parent selector-group]
         [stretchable-height #f]
         [alignment '(left center)]
         [spacing 8]))

  (define text-editor (new text%))
  (define canvas-editor
    (new editor-canvas%
         [parent selector-group]
         [editor text-editor]
         [style '(auto-hscroll auto-vscroll)]))

  (define (update-example-view! idx)
    (when (and (pair? examples) (< idx (length examples)))
      (define sel (list-ref examples idx))
      (define code (read-example-code (hash-ref sel 'arquivo)))
      (send text-editor begin-edit-sequence)
      (send text-editor erase)
      (send text-editor insert code)
      (send text-editor change-style
            (make-object style-delta% 'change-family 'modern)
            0
            (send text-editor last-position))
      (send text-editor set-position 0)
      (send text-editor scroll-to-position 0)
      (send text-editor end-edit-sequence)))

  (define example-choice
    (new choice%
         [parent choice-panel]
         [label "Exemplo: "]
         [choices (if (pair? choices) choices '("Nenhum exemplo disponível"))]
         [selection initial-idx]
         [callback (lambda (c e)
                     (update-example-view! (send c get-selection)))]))

  (new button%
       [parent choice-panel]
       [label "📋 Copiar Código"]
       [callback (lambda (b e)
                   (define code-str (send text-editor get-text))
                   (send the-clipboard set-clipboard-string code-str (current-seconds))
                   (message-box "Código Copiado"
                                "O código de exemplo foi copiado para a área de transferência!\nVocê pode colá-lo no editor do DrRacket com Ctrl+V."
                                dlg
                                '(ok)))])

  (define bottom-panel
    (new horizontal-panel%
         [parent main-panel]
         [alignment '(right center)]
         [stretchable-height #f]))

  (new button%
       [parent bottom-panel]
       [label "Fechar"]
       [callback (lambda (b e) (send dlg show #f))])

  (update-example-view! initial-idx)
  (queue-callback
   (lambda ()
     (send text-editor set-position 0)
     (send text-editor scroll-to-position 0))
   #f)
  (send dlg show #t))
