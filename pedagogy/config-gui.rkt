#lang racket/base

(require racket/gui/base
         racket/class
         racket/format
         racket/string
         racket/list
         racket/path
         "../tracker/config.rkt"
         "../tracker/state.rkt"
         "custom-content.rkt"
         "lessons-gui.rkt"
         "hints-gui.rkt")

(provide open-settings-window
         open-teacher-settings-window
         open-student-selection-window
         prompt-pin-auth-or-setup
         change-pin-dialog
         update-custom-content-lists!)

(define (prompt-pin-auth-or-setup [parent-window #f])
  (if (not (teacher-pin-registered?))
      (let ()
        (define dlg (new dialog%
                         [label "🔐 Cadastrar PIN do Mediador"]
                         [parent parent-window]
                         [width 400]
                         [height 250]))
        (define success? #f)

        (define panel (new vertical-panel% [parent dlg] [border 15] [spacing 10]))

        (new message%
             [parent panel]
             [label "Esta é a primeira vez que você acessa as Configurações.\nPor favor, cadastre um PIN para proteger o acesso docente:"])

        (define pin-field
          (new text-field%
               [parent panel]
               [label "Novo PIN: "]
               [style '(single password)]))

        (define confirm-field
          (new text-field%
               [parent panel]
               [label "Confirmar PIN: "]
               [style '(single password)]))

        (define buttons-panel (new horizontal-panel% [parent panel] [alignment '(center center)] [spacing 10]))

        (new button%
             [parent buttons-panel]
             [label "Salvar PIN e Acessar"]
             [callback (lambda (b e)
                         (define p1 (string-trim (send pin-field get-value)))
                         (define p2 (string-trim (send confirm-field get-value)))
                         (cond
                           [(string=? p1 "")
                            (message-box "Aviso" "O PIN não pode ser vazio!" dlg '(ok stop))]
                           [(not (string=? p1 p2))
                            (message-box "Aviso" "Os PINs digitados não conferem!" dlg '(ok stop))]
                           [else
                            (save-teacher-pin! p1)
                            (set! success? #t)
                            (send dlg show #f)
                            (message-box "PIN Cadastrado"
                                         "PIN do mediador cadastrado com sucesso!\nGuarde este PIN para os próximos acessos."
                                         #f
                                         '(ok))]))])

        (new button%
             [parent buttons-panel]
             [label "Cancelar"]
             [callback (lambda (b e) (send dlg show #f))])

        (send dlg show #t)
        success?)

      (let ()
        (define dlg (new dialog%
                         [label "🔒 Acesso Restrito ao Mediador"]
                         [parent parent-window]
                         [width 360]
                         [height 190]))
        (define success? #f)

        (define panel (new vertical-panel% [parent dlg] [border 15] [spacing 10]))

        (new message%
             [parent panel]
             [label "Digite o PIN de segurança para acessar o Painel de Configurações:"])

        (define pin-field
          (new text-field%
               [parent panel]
               [label "PIN: "]
               [style '(single password)]))

        (define buttons-panel (new horizontal-panel% [parent panel] [alignment '(center center)] [spacing 10]))

        (new button%
             [parent buttons-panel]
             [label "Entrar"]
             [callback (lambda (b e)
                         (define typed-pin (send pin-field get-value))
                         (if (verify-teacher-pin typed-pin)
                             (begin
                               (set! success? #t)
                               (send dlg show #f))
                             (message-box "Acesso Negado" "PIN incorreto! Tente novamente." dlg '(ok stop))))])

        (new button%
             [parent buttons-panel]
             [label "Cancelar"]
             [callback (lambda (b e) (send dlg show #f))])

        (send dlg show #t)
        success?)))

(define (change-pin-dialog [parent-window #f])
  (define dlg (new dialog%
                   [label "🔑 Alterar PIN do Mediador"]
                   [parent parent-window]
                   [width 380]
                   [height 260]))
  (define panel (new vertical-panel% [parent dlg] [border 15] [spacing 10]))

  (define current-field
    (new text-field%
         [parent panel]
         [label "PIN Atual: "]
         [style '(single password)]))

  (define new-field
    (new text-field%
         [parent panel]
         [label "Novo PIN: "]
         [style '(single password)]))

  (define confirm-field
    (new text-field%
         [parent panel]
         [label "Confirmar Novo PIN: "]
         [style '(single password)]))

  (define buttons-panel (new horizontal-panel% [parent panel] [alignment '(center center)] [spacing 10]))

  (new button%
       [parent buttons-panel]
       [label "Atualizar PIN"]
       [callback (lambda (b e)
                   (define at (send current-field get-value))
                   (define nv (string-trim (send new-field get-value)))
                   (define cf (string-trim (send confirm-field get-value)))
                   (cond
                     [(not (verify-teacher-pin at))
                      (message-box "Erro" "O PIN atual digitado está incorreto!" dlg '(ok stop))]
                     [(string=? nv "")
                      (message-box "Erro" "O novo PIN não pode ser vazio!" dlg '(ok stop))]
                     [(not (string=? nv cf))
                      (message-box "Erro" "A confirmação não coincide com o novo PIN!" dlg '(ok stop))]
                     [else
                      (save-teacher-pin! nv)
                      (message-box "PIN Atualizado" "PIN de segurança atualizado com sucesso!" dlg '(ok))
                      (send dlg show #f)]))])

  (new button%
       [parent buttons-panel]
       [label "Cancelar"]
       [callback (lambda (b e) (send dlg show #f))])

  (send dlg show #t))

(define SETTINGS-WINDOW-FRAME #f)
(define SETTINGS-WINDOW-STUDENT-SELECTOR #f)
(define SETTINGS-WINDOW-LABEL-ACTIVE-STUDENT #f)
(define SETTINGS-WINDOW-LABEL-STUDENT-STATUS #f)
(define SETTINGS-WINDOW-P2 #f)
(define SETTINGS-WINDOW-P3 #f)
(define SETTINGS-WINDOW-RADIO #f)
(define SETTINGS-WINDOW-LESSONS-LIST #f)
(define SETTINGS-WINDOW-EXAMPLES-LIST #f)
(define SETTINGS-WINDOW-CALLBACK void)

(define (get-student-status-summary id)
  (define pts (get-student-points id))
  (define level (get-student-syntactic-level id))
  (define files (get-student-files id))
  (define total-files (hash-count files))
  (format "🏆 Pontuação: ~a pts   |   Nível Atual: ~a   |   Portfólio: ~a arquivo(s)" pts level total-files))

(define (update-custom-content-lists!)
  (when SETTINGS-WINDOW-LESSONS-LIST
    (send SETTINGS-WINDOW-LESSONS-LIST clear)
    (for ([a (list-custom-lessons)])
      (send SETTINGS-WINDOW-LESSONS-LIST append a)))
  (when SETTINGS-WINDOW-EXAMPLES-LIST
    (send SETTINGS-WINDOW-EXAMPLES-LIST clear)
    (for ([e (list-custom-examples)])
      (send SETTINGS-WINDOW-EXAMPLES-LIST append e))))

(define (open-settings-window [update-callback void] [ignore-pin? #f])
  (set! SETTINGS-WINDOW-CALLBACK update-callback)

  (define authenticated?
    (if ignore-pin?
        #t
        (prompt-pin-auth-or-setup)))

  (when authenticated?
    (define cfg (load-teacher-config))
    (define current-student (get-current-student))
    (define current-index
      (case (hash-ref cfg 'nivel_forcado #f)
        [(1) 1]
        [(2) 2]
        [(3) 3]
        [else 0]))

    (if SETTINGS-WINDOW-FRAME
        (let ()
          (define current-list (list-all-students))
          (send SETTINGS-WINDOW-STUDENT-SELECTOR clear)
          (for ([a current-list]) (send SETTINGS-WINDOW-STUDENT-SELECTOR append a))
          (define sel-idx (or (index-of current-list (get-current-student)) 0))
          (send SETTINGS-WINDOW-STUDENT-SELECTOR set-selection sel-idx)
          (when SETTINGS-WINDOW-LABEL-ACTIVE-STUDENT
            (send SETTINGS-WINDOW-LABEL-ACTIVE-STUDENT set-label (format " ~a " (get-current-student))))
          (send SETTINGS-WINDOW-LABEL-STUDENT-STATUS set-label (get-student-status-summary (get-current-student)))
          (send SETTINGS-WINDOW-P2 set-value (number->string (hash-ref cfg 'pontos_nivel_2 4)))
          (send SETTINGS-WINDOW-P3 set-value (number->string (hash-ref cfg 'pontos_nivel_3 8)))
          (send SETTINGS-WINDOW-RADIO set-selection current-index)
          (update-custom-content-lists!)
          (send SETTINGS-WINDOW-FRAME show #t)
          (send SETTINGS-WINDOW-FRAME focus))
        (let ()
          (define frame (new frame%
                             [label "Painel de Configurações do Mediador e Conteúdo Pedagógico"]
                             [width 640]
                             [height 680]))
          (set! SETTINGS-WINDOW-FRAME frame)

          (define main-panel (new vertical-panel% [parent frame] [border 12] [spacing 10]))

          (define tab-panel
            (new tab-panel%
                 [parent main-panel]
                 [choices '("👤 Aprendizes & Regras da Turma" "📚 Conteúdo Personalizado (Docente)")]
                 [callback (lambda (tp e)
                             (define sel (send tp get-selection))
                             (send tp change-children
                                   (lambda (c)
                                     (if (= sel 0)
                                         (list students-tab-panel)
                                         (list content-tab-panel)))))]))

          (define students-tab-panel (new vertical-panel% [parent tab-panel] [spacing 10]))

          (define students-group
            (new group-box-panel%
                 [parent students-tab-panel]
                 [label "👤 Seleção do Aluno da Sessão e Gestão da Turma"]))

          (define active-student-panel
            (new horizontal-panel%
                 [parent students-group]
                 [spacing 8]
                 [alignment '(left center)]))

          (new message%
               [parent active-student-panel]
               [label "🎓 Aluno Ativo na Sessão:"]
               [font (make-object font% 10 'default 'normal 'bold)])

          (define active-student-label
            (new message%
                 [parent active-student-panel]
                 [label (format " ~a " current-student)]
                 [auto-resize #t]
                 [font (make-object font% 11 'default 'normal 'bold)]))
          (set! SETTINGS-WINDOW-LABEL-ACTIVE-STUDENT active-student-label)

          (define students-list (list-all-students))
          (define idx-sel (or (index-of students-list current-student) 0))

          (define (apply-student-selection! student-name)
            (set-current-student! student-name)
            (send active-student-label set-label (format " ~a " student-name))
            (send status-label set-label (get-student-status-summary student-name))
            (SETTINGS-WINDOW-CALLBACK))

          (define selector-row-panel
            (new horizontal-panel%
                 [parent students-group]
                 [spacing 8]
                 [alignment '(left center)]))

          (define student-selector
            (new choice%
                 [parent selector-row-panel]
                 [label "Escolher Aluno: "]
                 [choices students-list]
                 [selection idx-sel]
                 [stretchable-width #t]
                 [callback (lambda (c e)
                             (define al (send c get-string-selection))
                             (send status-label set-label (get-student-status-summary al)))]))
          (set! SETTINGS-WINDOW-STUDENT-SELECTOR student-selector)

          (new button%
               [parent selector-row-panel]
               [label "⭐ Selecionar Aluno da Sessão"]
               [callback (lambda (b e)
                           (define al-sel (send student-selector get-string-selection))
                           (when (non-empty-string? al-sel)
                             (apply-student-selection! al-sel)
                             (message-box "Aluno da Sessão Definido"
                                          (format "O aluno '~a' agora é o aprendiz ativo desta sessão no DrRacket!\n\nA barra de status e métricas foram atualizadas." al-sel)
                                          frame
                                          '(ok))))])

          (define status-label
            (new message%
                 [parent students-group]
                 [label (get-student-status-summary current-student)]
                 [auto-resize #t]
                 [font (make-object font% 10 'default 'normal 'normal)]))
          (set! SETTINGS-WINDOW-LABEL-STUDENT-STATUS status-label)

          (define student-actions-panel
            (new horizontal-panel%
                 [parent students-group]
                 [spacing 10]
                 [alignment '(center center)]))

          (new button%
               [parent student-actions-panel]
               [label "🔄 Reiniciar Progresso do Aluno"]
               [callback (lambda (b e)
                           (define al-sel (send student-selector get-string-selection))
                           (define resp
                             (message-box "Confirmar Reinício"
                                          (format "Deseja realmente zerar a pontuação e progresso do aluno '~a'?\n\nA conta do aluno será mantida, mas a pontuação e atividades começarão do zero." al-sel)
                                          frame
                                          '(yes-no caution)))
                           (when (eq? resp 'yes)
                             (reset-student-progress! al-sel)
                             (send status-label set-label (get-student-status-summary al-sel))
                             (SETTINGS-WINDOW-CALLBACK)
                             (message-box "Progresso Reiniciado"
                                          (format "O progresso do aluno '~a' foi reiniciado com sucesso!" al-sel)
                                          frame
                                          '(ok))))])

          (new button%
               [parent student-actions-panel]
               [label "🗑️ Remover Cadastro do Aluno"]
               [callback (lambda (b e)
                           (define al-sel (send student-selector get-string-selection))
                           (define resp
                             (message-box "Confirmar Remoção"
                                          (format "Tem certeza que deseja EXCLUIR permanentemente o cadastro e histórico do aluno '~a'?\n\nEsta operação não pode ser desfeita." al-sel)
                                          frame
                                          '(yes-no caution)))
                           (when (eq? resp 'yes)
                             (remove-student! al-sel)
                             (define novas (list-all-students))
                             (send student-selector clear)
                             (for ([a novas]) (send student-selector append a))
                             (define novo-atual (get-current-student))
                             (define n-idx (or (index-of novas novo-atual) 0))
                             (send student-selector set-selection n-idx)
                             (send active-student-label set-label (format " ~a " novo-atual))
                             (send status-label set-label (get-student-status-summary novo-atual))
                             (SETTINGS-WINDOW-CALLBACK)
                             (message-box "Aluno Removido"
                                          (format "O aluno '~a' foi excluído do sistema." al-sel)
                                          frame
                                          '(ok))))])

          (define create-student-panel
            (new horizontal-panel%
                 [parent students-group]
                 [spacing 8]
                 [alignment '(left center)]))

          (define new-name-field
            (new text-field%
                 [parent create-student-panel]
                 [label "Criar Novo Aluno: "]
                 [stretchable-width #t]))

          (new button%
               [parent create-student-panel]
               [label "➕ Cadastrar e Ativar na Sessão"]
               [callback (lambda (b e)
                           (define nome-novo (string-trim (send new-name-field get-value)))
                           (cond
                             [(string=? nome-novo "")
                              (message-box "Aviso" "Digite o nome ou identificador do novo aluno!" frame '(ok stop))]
                             [else
                              (register-new-student! nome-novo)
                              (define novas (list-all-students))
                              (send student-selector clear)
                              (for ([a novas]) (send student-selector append a))
                              (define n-idx (or (index-of novas nome-novo) 0))
                              (send student-selector set-selection n-idx)
                              (send active-student-label set-label (format " ~a " nome-novo))
                              (send status-label set-label (get-student-status-summary nome-novo))
                              (send new-name-field set-value "")
                              (SETTINGS-WINDOW-CALLBACK)
                              (message-box "Aluno Cadastrado"
                                           (format "O aluno '~a' foi criado e ativado como aluno da sessão com sucesso!" nome-novo)
                                           frame
                                           '(ok))]))])

          (define rules-group
            (new group-box-panel%
                 [parent students-tab-panel]
                 [label "⚙️ Regras Pedagógicas e Metas de Nível"]))

          (define field-p2
            (new text-field%
                 [parent rules-group]
                 [label "Pontos para Nível 2 (Transição): "]
                 [init-value (number->string (hash-ref cfg 'pontos_nivel_2 4))]))
          (set! SETTINGS-WINDOW-P2 field-p2)

          (define field-p3
            (new text-field%
                 [parent rules-group]
                 [label "Pontos para Nível 3 (Autonomia HtDP): "]
                 [init-value (number->string (hash-ref cfg 'pontos_nivel_3 8))]))
          (set! SETTINGS-WINDOW-P3 field-p3)

          (define lock-choices
            '("Automático (progressão conforme pontuação do aluno)"
              "Travar Turma no Nível 1 (Apenas Português)"
              "Travar Turma no Nível 2 (Transição Bilíngue)"
              "Travar Turma no Nível 3 (HtDP Oficial)"))

          (define mode-radio
            (new radio-box%
                 [parent rules-group]
                 [label "Modo de Aplicação na Aula:"]
                 [choices lock-choices]
                 [selection current-index]))
          (set! SETTINGS-WINDOW-RADIO mode-radio)

          (define security-group
            (new group-box-panel%
                 [parent students-tab-panel]
                 [label "🔒 Segurança do Mediador"]))

          (define pin-info-panel (new horizontal-panel% [parent security-group] [alignment '(left center)] [spacing 10]))
          (new message%
               [parent pin-info-panel]
               [label "O acesso a este painel está protegido por PIN."])
          (new button%
               [parent pin-info-panel]
               [label "🔑 Alterar PIN de Acesso"]
               [callback (lambda (b e) (change-pin-dialog frame))])

          (define content-tab-panel (new vertical-panel% [parent tab-panel] [spacing 10]))

          (define info-banner-panel
            (new vertical-panel%
                 [parent content-tab-panel]
                 [style '(border)]
                 [stretchable-height #f]
                 [border 8]))

          (new message%
               [parent info-banner-panel]
               [label "ℹ️ Os conteúdos que acompanham a instalação do pacote são protegidos contra modificações.\nAqui você pode adicionar novos roteiros de aula ou exemplos de código criados para a sua turma:"]
               [auto-resize #t]
               [font (make-object font% 9 'default 'normal 'normal)])

          (define lessons-group
            (new group-box-panel%
                 [parent content-tab-panel]
                 [label "📖 Roteiros de Aula Personalizados (Lessons)"]))

          (define lessons-list-box
            (new list-box%
                 [parent lessons-group]
                 [label #f]
                 [choices (list-custom-lessons)]
                 [style '(single)]
                 [min-height 110]
                 [stretchable-height #t]))
          (set! SETTINGS-WINDOW-LESSONS-LIST lessons-list-box)

          (define lessons-buttons-panel
            (new horizontal-panel%
                 [parent lessons-group]
                 [spacing 10]
                 [alignment '(left center)]
                 [stretchable-height #f]))

          (new button%
               [parent lessons-buttons-panel]
               [label "➕ Adicionar Nova Aula..."]
               [callback
                (lambda (b e)
                  (define file-path
                    (get-file "Selecione o arquivo da aula (.md, .rkt, .txt)"
                              frame
                              #f
                              #f
                              #f
                              '()
                              '(("Roteiros de Aula (*.md;*.rkt;*.txt)" "*.md;*.rkt;*.txt")
                                ("Todos os Arquivos (*.*)" "*.*"))))
                  (when file-path
                    (define-values (base file-sub-path dir?) (split-path file-path))
                    (define name-str (path->string file-sub-path))
                    (define proceed? #t)
                    (when (custom-lesson? name-str)
                      (define resp
                        (message-box "Substituir Aula"
                                     (format "Já existe uma aula personalizada com o nome '~a'. Deseja substituí-la?" name-str)
                                     frame
                                     '(yes-no caution)))
                      (set! proceed? (eq? resp 'yes)))
                    (when proceed?
                      (add-custom-lesson! file-path name-str)
                      (update-custom-content-lists!)
                      (load-available-lessons #t)
                      (message-box "Aula Adicionada"
                                   (format "A aula '~a' foi adicionada com sucesso e já está disponível na janela de Aulas!" name-str)
                                   frame
                                   '(ok)))))])

          (new button%
               [parent lessons-buttons-panel]
               [label "🗑️ Remover Aula"]
               [callback
                (lambda (b e)
                  (define sel (send lessons-list-box get-string-selection))
                  (cond
                    [(not sel)
                     (message-box "Aviso" "Selecione uma aula personalizada na lista para remover!" frame '(ok stop))]
                    [else
                     (define resp
                       (message-box "Confirmar Remoção"
                                    (format "Deseja realmente remover o arquivo de aula personalizada '~a'?" sel)
                                    frame
                                    '(yes-no caution)))
                     (when (eq? resp 'yes)
                       (remove-custom-lesson! sel)
                       (update-custom-content-lists!)
                       (load-available-lessons #t)
                       (message-box "Aula Removida"
                                    (format "A aula personalizada '~a' foi removida com sucesso." sel)
                                    frame
                                    '(ok)))]))])

          (define examples-group
            (new group-box-panel%
                 [parent content-tab-panel]
                 [label "💡 Exemplos de Código Personalizados (Examples)"]))

          (define examples-list-box
            (new list-box%
                 [parent examples-group]
                 [label #f]
                 [choices (list-custom-examples)]
                 [style '(single)]
                 [min-height 110]
                 [stretchable-height #t]))
          (set! SETTINGS-WINDOW-EXAMPLES-LIST examples-list-box)

          (define examples-buttons-panel
            (new horizontal-panel%
                 [parent examples-group]
                 [spacing 10]
                 [alignment '(left center)]
                 [stretchable-height #f]))

          (new button%
               [parent examples-buttons-panel]
               [label "➕ Adicionar Novo Exemplo..."]
               [callback
                (lambda (b e)
                  (define file-path
                    (get-file "Selecione o arquivo de código de exemplo (.rkt)"
                              frame
                              #f
                              #f
                              #f
                              '()
                              '(("Código de Exemplo Racket (*.rkt)" "*.rkt")
                                ("Todos os Arquivos (*.*)" "*.*"))))
                  (when file-path
                    (define-values (base file-sub-path dir?) (split-path file-path))
                    (define name-str (path->string file-sub-path))
                    (define proceed? #t)
                    (when (custom-example? name-str)
                      (define resp
                        (message-box "Substituir Exemplo"
                                     (format "Já existe um exemplo personalizado com o nome '~a'. Deseja substituí-lo?" name-str)
                                     frame
                                     '(yes-no caution)))
                      (set! proceed? (eq? resp 'yes)))
                    (when proceed?
                      (add-custom-example! file-path name-str)
                      (update-custom-content-lists!)
                      (load-available-examples #t)
                      (message-box "Exemplo Adicionado"
                                   (format "O exemplo '~a' foi adicionado com sucesso e já está disponível na janela de Dicas!" name-str)
                                   frame
                                   '(ok)))))])

          (new button%
               [parent examples-buttons-panel]
               [label "🗑️ Remover Exemplo"]
               [callback
                (lambda (b e)
                  (define sel (send examples-list-box get-string-selection))
                  (cond
                    [(not sel)
                     (message-box "Aviso" "Selecione um exemplo personalizado na lista para remover!" frame '(ok stop))]
                    [else
                     (define resp
                       (message-box "Confirmar Remoção"
                                    (format "Deseja realmente remover o arquivo de exemplo personalizado '~a'?" sel)
                                    frame
                                    '(yes-no caution)))
                     (when (eq? resp 'yes)
                       (remove-custom-example! sel)
                       (update-custom-content-lists!)
                       (load-available-examples #t)
                       (message-box "Exemplo Removido"
                                    (format "O exemplo personalizado '~a' foi removido com sucesso." sel)
                                    frame
                                    '(ok)))]))])

          (send tab-panel change-children (lambda (c) (list students-tab-panel)))

          (define buttons-panel (new horizontal-panel% [parent main-panel] [alignment '(center center)] [spacing 15]))

          (new button%
               [parent buttons-panel]
               [label "Salvar Configurações"]
               [callback (lambda (b e)
                           (define student-sel (send student-selector get-string-selection))
                           (when (non-empty-string? student-sel)
                             (apply-student-selection! student-sel))

                           (define p2 (or (string->number (send field-p2 get-value)) 4))
                           (define p3 (or (string->number (send field-p3 get-value)) 8))
                           (define sel (send mode-radio get-selection))
                           (define forced-level
                             (case sel
                               [(1) 1]
                               [(2) 2]
                               [(3) 3]
                               [else #f]))
                           (define current-cfg (load-teacher-config))
                           (define new-cfg
                             (hash-set* current-cfg
                                        'pontos_nivel_2 p2
                                        'pontos_nivel_3 p3
                                        'nivel_forcado forced-level))
                           (save-teacher-config! new-cfg)

                           (SETTINGS-WINDOW-CALLBACK)
                           (message-box "Configurações Atualizadas"
                                        (format "Aluno ativo: ~a\nRegras de nível salvas com sucesso!" (get-current-student))
                                        frame
                                        '(ok))
                           (send frame show #f))])

          (new button%
               [parent buttons-panel]
               [label "Fechar"]
               [callback (lambda (b e) (send frame show #f))])

          (send frame show #t)))))

(define (open-teacher-settings-window [callback void])
  (open-settings-window callback))

(define (open-student-selection-window [callback void])
  (open-settings-window callback))
