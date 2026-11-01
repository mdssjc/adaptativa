#lang racket/base

(require racket/gui/base
         racket/class
         racket/unit
         file/sha1
         drracket/tool
         "pedagogy/teacher-report.rkt"
         "pedagogy/config-gui.rkt"
         "pedagogy/hints-gui.rkt"
         "pedagogy/lessons-gui.rkt"
         "tracker/state.rkt"
         "tracker/config.rkt")

(provide tool@)

(putenv "AMB_DRRACKET" "true")

(define panel-order-enforcing%
  (class horizontal-panel%
    (super-new)
    (define fixed-order null)
    (define/public (set-fixed-order! order) (set! fixed-order order))
    (define/override (change-children f)
      (super change-children
             (lambda (children)
               (define new-children (f children))
               (if (null? fixed-order)
                   new-children
                   (filter (lambda (c) (memq c new-children)) fixed-order)))))))

(define tool@
  (unit
    (import drracket:tool^)
    (export drracket:tool-exports^)

    (define (phase1) (void))
    (define (phase2) (void))

    (drracket:get/extend:extend-unit-frame
     (lambda (super%)
       (class super%
         (super-new)
         (inherit get-button-panel
                  get-definitions-text)

         (define button-panel (get-button-panel))

         (define (get-full-label)
           (define student (get-current-student))
           (define pts (get-student-points student))
           (define level (get-student-syntactic-level student))
           (define level-desc
             (case level
               [(1) "1 (Português)"]
               [(2) "2 (Transição)"]
               [(3) "3 (HTdP Oficial)"]
               [else (number->string level)]))
           (format "🎓 Aluno: ~a | Pontos: ~a | Nível: ~a" student pts level-desc))

         (define last-label (get-full-label))

         (define adaptive-panel
           (new panel-order-enforcing%
                [parent button-panel]
                [alignment '(left center)]
                [spacing 10]
                [stretchable-width #f]
                [stretchable-height #f]))

         (define status-label
           (new message%
                [parent adaptive-panel]
                [label last-label]
                [auto-resize #t]
                [stretchable-width #f]
                [stretchable-height #f]))

         (define action-panel
           (new panel-order-enforcing%
                [parent adaptive-panel]
                [alignment '(left center)]
                [spacing 4]
                [stretchable-width #f]
                [stretchable-height #f]))

         (define btn-config
           (new button%
                [parent action-panel]
                [label "⚙️ Configurações"]
                [callback (lambda (b e)
                            (open-settings-window update-bar!))]))

         (define btn-lessons
           (new button%
                [parent action-panel]
                [label "📚 Aulas"]
                [callback (lambda (b e)
                            (open-lessons-window))]))

         (define btn-hints
           (new button%
                [parent action-panel]
                [label "💡 Dica"]
                [callback (lambda (b e)
                            (open-adaptive-hints-window))]))

         (define btn-report
           (new button%
                [parent action-panel]
                [label "📊 Relatório"]
                [callback (lambda (b e)
                            (open-teacher-report-window (get-current-student)))]))

         (send adaptive-panel set-fixed-order! (list status-label action-panel))
         (send action-panel set-fixed-order! (list btn-config btn-lessons btn-hints btn-report))

         (queue-callback
          (lambda ()
            (with-handlers ([exn:fail? (lambda (e) (void))])
              (send button-panel change-children
                    (lambda (children)
                      (if (memq adaptive-panel children)
                          (cons adaptive-panel (remq adaptive-panel children))
                          children)))))
          #f)

         (define (update-bar!)
           (define new-label (get-full-label))
           (unless (equal? new-label last-label)
             (set! last-label new-label)
             (send status-label set-label new-label)))

         (define/public (update-adaptive-status)
           (update-bar!))

         (define/override (execute-callback)
           (with-handlers ([exn:fail? (lambda (e) (void))])
             (define defs (get-definitions-text))
             (when defs
               (define max-len (min 300 (send defs last-position)))
               (define header (send defs get-text 0 max-len))
               (when (regexp-match? #px"^\\s*#lang\\s+adaptativa\\b" header)
                 (define fn (send defs get-filename))
                 (define path-str
                   (cond
                     [(path? fn) (path->string fn)]
                     [(string? fn) fn]
                     [else
                      (define port-name (send defs get-port-name))
                      (if (string? port-name) port-name "sem-titulo.rkt")]))
                 (define code-str (send defs get-text 0 (send defs last-position)))
                 (define hash-str (sha1 (open-input-string code-str)))
                 (authorize-next-execution! path-str hash-str))))
           (super execute-callback))

         (define/override (update-running running?)
           (super update-running running?)
           (unless running?
             (clear-profile-cache!)
             (queue-callback (lambda () (update-bar!)) #f)))

         (define timer-sync
           (new timer%
                [interval 5000]
                [notify-callback (lambda () (update-bar!))])))))))
