#lang racket/base

(require racket/gui/base
         racket/class
         racket/file
         racket/path
         racket/string
         racket/format
         racket/list
         "../tracker/state.rkt"
         "../tracker/config.rkt"
         "custom-content.rkt")

(provide open-lessons-window
         load-available-lessons
         extract-lesson-metadata
         extract-lesson-code
         render-colored-lesson!
         get-lessons-directory
         read-lesson-content)

(define (get-lessons-directory)
  (get-default-lessons-dir))

(define (extract-lesson-metadata file-path filename [customized? #f])
  (define lines
    (with-handlers ([exn:fail? (lambda (e) '())])
      (file->lines file-path)))

  (define rx-lesson #px"(?i:^\\s*(?:;+|#+).*@?(?:aula|licao|lição)\\s*[:=]?\\s*([0-9]+))")
  (define rx-level #px"(?i:^\\s*(?:;+|#+).*@?(?:nivel|nível)\\s*[:=]\\s*([0-9]+))")
  (define rx-title #px"(?i:^\\s*(?:;+|#+).*@?(?:titulo|título)\\s*[:=]\\s*(.+))")
  (define rx-header-md #px"^#\\s+Aula\\s+([0-9]+)[:\\-\\s]*(.+)")

  (define lesson-num #f)
  (define level-num #f)
  (define title-str #f)

  (for ([l lines])
    (cond
      [(and (not lesson-num) (regexp-match rx-lesson l))
       => (lambda (m) (set! lesson-num (string->number (cadr m))))])
    (cond
      [(and (not level-num) (regexp-match rx-level l))
       => (lambda (m) (set! level-num (string->number (cadr m))))])
    (cond
      [(and (not title-str) (regexp-match rx-title l))
       => (lambda (m) (set! title-str (string-trim (cadr m))))])
    (cond
      [(and (not title-str) (regexp-match rx-header-md l))
       => (lambda (m)
            (unless lesson-num (set! lesson-num (string->number (cadr m))))
            (set! title-str (string-trim (caddr m))))]))

  (define lesson
    (or lesson-num
        (let ([m (regexp-match #px"^([0-9]+)" filename)])
          (if m (string->number (cadr m)) 1))))

  (define level
    (or level-num
        (let ([m (regexp-match #px"(?i:nivel([0-9]+)|level([0-9]+))" filename)])
          (if m (string->number (or (cadr m) (caddr m))) 1))))

  (define title
    (or title-str
        (let* ([without-ext (regexp-replace #px"\\.(md|txt|rkt)$" filename "")]
               [without-num (regexp-replace #px"^[0-9]+-(?:aula-)?" without-ext "")]
               [words (string-split without-num "-")])
          (string-join (map string-titlecase words) " "))))

  (define icon
    (case level
      [(1) "🌱"]
      [(2) "🌿"]
      [(3) "🌟"]
      [else "📚"]))

  (define label
    (if customized?
        (format "~a Aula ~a: ~a (Nível ~a) ✏️ [Docente]"
                icon
                (~r lesson #:min-width 2 #:pad-string "0")
                title
                level)
        (format "~a Aula ~a: ~a (Nível ~a)"
                icon
                (~r lesson #:min-width 2 #:pad-string "0")
                title
                level)))

  (hash 'arquivo filename
        'aula lesson
        'nivel level
        'titulo title
        'icone icon
        'label label
        'caminho file-path
        'customizada? customized?))

(define (load-available-lessons [force-reload? #f])
  (define standard-dir (get-default-lessons-dir))
  (define standard-items
    (if (directory-exists? standard-dir)
        (filter (lambda (p)
                  (and (or (path-has-extension? p #".md")
                           (path-has-extension? p #".txt")
                           (path-has-extension? p #".rkt"))
                       (file-exists? (build-path standard-dir p))))
                (directory-list standard-dir))
        '()))

  (define standard-lessons
    (for/list ([p standard-items])
      (define fn (path->string p))
      (define full-path (build-path standard-dir p))
      (extract-lesson-metadata full-path fn #f)))

  (define custom-dir (get-custom-lessons-dir))
  (define custom-items
    (if (directory-exists? custom-dir)
        (filter (lambda (p)
                  (and (or (path-has-extension? p #".md")
                           (path-has-extension? p #".txt")
                           (path-has-extension? p #".rkt"))
                       (file-exists? (build-path custom-dir p))))
                (directory-list custom-dir))
        '()))

  (define custom-lessons
    (for/list ([p custom-items])
      (define fn (path->string p))
      (define full-path (build-path custom-dir p))
      (extract-lesson-metadata full-path fn #t)))

  (define all-lessons (append standard-lessons custom-lessons))

  (sort all-lessons
        (lambda (a b)
          (define lvl-a (hash-ref a 'nivel 1))
          (define lvl-b (hash-ref b 'nivel 1))
          (if (= lvl-a lvl-b)
              (let ([num-a (hash-ref a 'aula 0)]
                    [num-b (hash-ref b 'aula 0)])
                (if (= num-a num-b)
                    (string<? (hash-ref a 'arquivo "") (hash-ref b 'arquivo ""))
                    (< num-a num-b)))
              (< lvl-a lvl-b)))))

(define (read-lesson-content filename)
  (define custom-path (build-path (get-custom-lessons-dir) filename))
  (define target-path
    (if (file-exists? custom-path)
        custom-path
        (build-path (get-default-lessons-dir) filename)))
  (if (file-exists? target-path)
      (file->string target-path)
      "# Conteúdo da Aula Não Encontrado."))

(define (extract-lesson-code markdown-text)
  (define lines (string-split markdown-text "\n"))
  (define in-code? #f)
  (define current-block '())
  (define blocks '())
  (for ([l lines])
    (cond
      [(regexp-match? #px"^```" l)
       (if in-code?
           (begin
             (set! in-code? #f)
             (when (pair? current-block)
               (set! blocks (cons (string-join (reverse current-block) "\n") blocks))
               (set! current-block '())))
           (set! in-code? #t))]
      [in-code?
       (set! current-block (cons l current-block))]))
  (if (pair? blocks)
      (string-join (reverse blocks) "\n\n;; ------------------------------------------\n\n")
      ";; Nenhum bloco de código delimitado por ```racket encontrado nesta aula."))

(define (render-colored-lesson! editor markdown-text)
  (send editor begin-edit-sequence)
  (send editor erase)

  (define font-family 'default)
  (define base-font-size 13)

  (define normal-style (make-object style-delta% 'change-family font-family))
  (send normal-style set-delta-face "Segoe UI")
  (send normal-style set-size-mult 0.0)
  (send normal-style set-size-add base-font-size)
  (send normal-style set-delta-foreground (make-object color% 20 20 20))
  (send normal-style set-weight-on 'normal)

  (define (append-styled-line! txt [weight 'normal] [color (make-object color% 20 20 20)] [font-size base-font-size] [family 'default] [italic? #f])
    (define start-pos (send editor last-position))
    (send editor insert txt)
    (define end-pos (send editor last-position))
    (define delta (make-object style-delta% 'change-family family))
    (send delta set-delta-face (if (equal? family 'modern) "Consolas" "Segoe UI"))
    (send delta set-size-mult 0.0)
    (send delta set-size-add font-size)
    (send delta set-delta-foreground color)
    (if (equal? weight 'bold)
        (send delta set-weight-on 'bold)
        (send delta set-weight-on 'normal))
    (if italic?
        (send delta set-style-on 'italic)
        (send delta set-style-on 'normal))
    (send editor change-style delta start-pos end-pos))

  (define (clean-markdown-inline text-line)
    (let* ([s text-line]
           [s (regexp-replace* #px"`([^`]+)`" s "\\1")]
           [s (regexp-replace* #px"\\*\\*([^*]+)\\*\\*" s "\\1")]
           [s (regexp-replace* #px"\\*([^*]+)\\*" s "\\1")])
      s))

  (define (render-markdown-table-block! raw-rows)
    (define parsed-rows
      (for/list ([row raw-rows])
        (define cells (string-split row "|"))
        (define trimmed (map (lambda (c) (clean-markdown-inline (string-trim c))) cells))
        (define content-cells
          (filter (lambda (c) (and (non-empty-string? c) (not (regexp-match? #px"^:?-+:?$" c)))) trimmed))
        content-cells))

    (define valid-rows (filter pair? parsed-rows))
    (when (pair? valid-rows)
      (define col-count (apply max (map length valid-rows)))
      (define col-widths
        (for/list ([col-idx (in-range col-count)])
          (define max-w
            (for/fold ([current-max 4])
                      ([row valid-rows])
              (if (< col-idx (length row))
                  (max current-max (string-length (list-ref row col-idx)))
                  current-max)))
          (+ max-w 2)))

      (define (render-border left-char mid-char right-char)
        (define segs
          (for/list ([w col-widths])
            (make-string w #\─)))
        (format "~a~a~a\n" left-char (string-join segs mid-char) right-char))

      (define top-border (render-border "┌" "┬" "┐"))
      (define mid-border (render-border "├" "┼" "┤"))
      (define bot-border (render-border "└" "┴" "┘"))

      (define (render-row-cells row)
        (define padded-cells
          (for/list ([col-idx (in-range col-count)])
            (define cell-text (if (< col-idx (length row)) (list-ref row col-idx) ""))
            (define width (list-ref col-widths col-idx))
            (define pad-len (- width (string-length cell-text) 1))
            (format " ~a~a" cell-text (make-string (max 0 pad-len) #\space))))
        (format "│~a│\n" (string-join padded-cells "│")))

      (append-styled-line! top-border 'normal (make-object color% 80 80 80) 12 'modern)
      (when (pair? valid-rows)
        (append-styled-line! (render-row-cells (car valid-rows)) 'bold (make-object color% 0 43 102) 12 'modern)
        (append-styled-line! mid-border 'normal (make-object color% 80 80 80) 12 'modern)
        (for ([row (cdr valid-rows)])
          (append-styled-line! (render-row-cells row) 'normal (make-object color% 40 40 40) 12 'modern)))
      (append-styled-line! bot-border 'normal (make-object color% 80 80 80) 12 'modern)
      (append-styled-line! "\n" 'normal (make-object color% 20 20 20) base-font-size 'default)))

  (define lines (string-split markdown-text "\n"))
  (define in-code? #f)
  (define table-rows '())

  (for ([line lines])
    (cond
      [(regexp-match? #px"^```" line)
       (when (pair? table-rows)
         (render-markdown-table-block! (reverse table-rows))
         (set! table-rows '()))
       (if in-code?
           (begin
             (set! in-code? #f)
             (append-styled-line! "\n" 'normal (make-object color% 20 20 20) base-font-size 'default))
           (begin
             (set! in-code? #t)
             (append-styled-line! "  ;; === Bloco de Código Educativo ===\n" 'italic (make-object color% 80 80 80) 11 'modern)))]

      [in-code?
       (append-styled-line! (format "  ~a\n" line) 'normal (make-object color% 51 51 51) 12 'modern)]

      [(regexp-match? #px"^\\s*\\|.*\\|\\s*$" line)
       (set! table-rows (cons line table-rows))]

      [else
       (when (pair? table-rows)
         (render-markdown-table-block! (reverse table-rows))
         (set! table-rows '()))

       (cond
         [(regexp-match #px"^#\\s+(.+)" line)
          => (lambda (m)
               (append-styled-line! (format "~a\n\n" (cadr m)) 'bold (make-object color% 0 0 0) 17 'default))]

         [(regexp-match #px"^##\\s+(.+)" line)
          => (lambda (m)
               (define title-text (cadr m))
               (if (regexp-match? #px"(?i:mediador|dica)" title-text)
                   (append-styled-line! (format "~a\n\n" title-text) 'bold (make-object color% 192 57 43) 14 'default)
                   (append-styled-line! (format "~a\n\n" title-text) 'bold (make-object color% 0 51 102) 14 'default)))]

         [(regexp-match #px"^###\\s+(.+)" line)
          => (lambda (m)
               (append-styled-line! (format "~a\n\n" (cadr m)) 'bold (make-object color% 44 62 80) 13 'default))]

         [(regexp-match #px"^\\s*-\\s+(.+)" line)
          => (lambda (m)
               (append-styled-line! (format "  • ~a\n" (clean-markdown-inline (cadr m))) 'normal (make-object color% 30 30 30) base-font-size 'default))]

         [(regexp-match #px"^\\s*\\*\\s+(.+)" line)
          => (lambda (m)
               (append-styled-line! (format "  • ~a\n" (clean-markdown-inline (cadr m))) 'normal (make-object color% 30 30 30) base-font-size 'default))]

         [(regexp-match #px"^\\s*[0-9]+\\.\\s+(.+)" line)
          => (lambda (m)
               (append-styled-line! (format "  ~a\n" (clean-markdown-inline line)) 'normal (make-object color% 30 30 30) base-font-size 'default))]

         [(string=? (string-trim line) "")
          (append-styled-line! "\n" 'normal (make-object color% 20 20 20) base-font-size 'default)]

         [else
          (append-styled-line! (format "~a\n" (clean-markdown-inline line)) 'normal (make-object color% 20 20 20) base-font-size 'default)])]))

  (when (pair? table-rows)
    (render-markdown-table-block! (reverse table-rows)))

  (send editor set-position 0)
  (send editor end-edit-sequence))

(define (open-lessons-window [parent-window #f])
  (define lessons (load-available-lessons #t))
  (define current-student (get-current-student))
  (define student-level (get-student-syntactic-level current-student))

  (define choices (map (lambda (a) (hash-ref a 'label)) lessons))

  (define initial-idx
    (let ([idx (for/first ([(a i) (in-indexed lessons)]
                          #:when (>= (hash-ref a 'nivel 1) student-level))
                 i)])
      (or idx 0)))

  (define dlg
    (new dialog%
         [label "📚 Roteiros e Conteúdos de Aula - Pensamento Computacional"]
         [parent parent-window]
         [width 920]
         [height 700]
         [style '(resize-border close-button)]))

  (define main-panel
    (new vertical-panel%
         [parent dlg]
         [border 12]
         [spacing 10]))

  (define top-panel
    (new horizontal-panel%
         [parent main-panel]
         [stretchable-height #f]
         [alignment '(left center)]
         [spacing 10]))

  (define text-editor (new text%))
  (send text-editor auto-wrap #t)
  (define canvas-editor
    (new editor-canvas%
         [parent main-panel]
         [editor text-editor]
         [style '(no-hscroll auto-vscroll)]))

  (define current-lesson-raw "")

  (define (update-lesson-view! idx)
    (when (and (pair? lessons) (< idx (length lessons)))
      (define sel (list-ref lessons idx))
      (define raw-content (read-lesson-content (hash-ref sel 'arquivo)))
      (set! current-lesson-raw raw-content)
      (render-colored-lesson! text-editor raw-content)))

  (define lesson-choice
    (new choice%
         [parent top-panel]
         [label "Selecione a Aula: "]
         [choices (if (pair? choices) choices '("Nenhuma aula cadastrada"))]
         [selection initial-idx]
         [callback (lambda (c e)
                     (update-lesson-view! (send c get-selection)))]))

  (new button%
       [parent top-panel]
       [label "📋 Copiar Exemplos da Aula"]
       [callback (lambda (b e)
                   (define codes (extract-lesson-code current-lesson-raw))
                   (send the-clipboard set-clipboard-string codes (current-seconds))
                   (message-box "Exemplos Copiados"
                                "Os códigos de exemplo da aula foram copiados!\nVocê pode colá-los no editor do DrRacket com Ctrl+V."
                                dlg
                                '(ok)))])

  (define bottom-panel
    (new horizontal-panel%
         [parent main-panel]
         [stretchable-height #f]
         [alignment '(right center)]))

  (new button%
       [parent bottom-panel]
       [label "Fechar"]
       [callback (lambda (b e) (send dlg show #f))])

  (update-lesson-view! initial-idx)
  (send dlg show #t))
