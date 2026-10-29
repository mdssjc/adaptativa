#lang racket/base

(require racket/gui/base
         racket/class
         racket/file
         racket/format
         racket/string
         racket/date
         racket/list
         json
         "../tracker/logger.rkt"
         "../tracker/timer.rkt"
         "../tracker/state.rkt"
         "../tracker/config.rkt")

(provide open-teacher-report-window
         generate-teacher-summary-text
         list-available-students
         render-colored-report!
         get-report-data
         clear-events-cache!)

(define EVENTS-CACHE '())
(define EVENTS-CACHE-KEY #f)

(define (clear-events-cache!)
  (set! EVENTS-CACHE '())
  (set! EVENTS-CACHE-KEY #f))

(define (load-event-history [force-reload? #f])
  (define path (get-log-file-path))
  (if (file-exists? path)
      (let* ([stamp (file-stat-stamp path)]
             [cache-key (cons (path->string path) stamp)])
        (if (and (pair? EVENTS-CACHE) (not force-reload?) stamp (equal? cache-key EVENTS-CACHE-KEY))
            EVENTS-CACHE
            (let ([events
                   (with-handlers ([exn:fail? (lambda (e) '())])
                     (for/list ([line (file->lines path)]
                                #:when (non-empty-string? line))
                       (with-handlers ([exn:fail? (lambda (e) #f)])
                         (string->jsexpr line))))])
              (set! EVENTS-CACHE events)
              (set! EVENTS-CACHE-KEY cache-key)
              events)))
      '()))

(define (list-available-students)
  (list-all-students))

(define (get-report-data [student-filter #f] [force-reload? #f])
  (define student-id (or student-filter (get-current-student)))
  (define events
    (filter (lambda (ev)
              (and (hash? ev)
                   (or (not student-id)
                       (equal? (hash-ref ev 'aluno #f) student-id))))
            (load-event-history force-reload?)))

  (define total (length events))
  (define successes (length (filter (lambda (ev) (equal? (hash-ref ev 'tipo #f) "sucesso")) events)))
  (define errors (length (filter (lambda (ev) (equal? (hash-ref ev 'tipo #f) "erro")) events)))
  (define sessions (length (filter (lambda (ev) (equal? (hash-ref ev 'tipo #f) "sessao")) events)))
  (define evaluated-count (+ successes errors))

  (define difficulty-counts (make-hash))
  (for ([ev events]
        #:when (equal? (hash-ref ev 'tipo #f) "erro"))
    (define cat (hash-ref ev 'categoria "geral"))
    (hash-set! difficulty-counts cat (+ (hash-ref difficulty-counts cat 0) 1)))

  (define level (get-student-syntactic-level student-id))
  (define level-desc
    (case level
      [(1) "🌱 Nível 1: Fundamentos & Expressão em Português"]
      [(2) "🌿 Nível 2: Tomada de Decisão Lógica, Testes & Repetição"]
      [(3) "🌟 Nível 3: Abstração Visual Avançada & HtDP Oficial"]
      [else "Roteiro Pedagógico Geral"]))

  (define files-map (get-student-files student-id))
  (define-values (total-category-points cats-map)
    (recalculate-points-by-categories files-map))

  (define accuracy-rate
    (if (and (> evaluated-count 0) (> successes 0))
        (* 100.0 (/ successes evaluated-count))
        0.0))

  (define performance-status
    (cond
      [(zero? evaluated-count)
       "⚪ Inicial (Aguardando Atividades Avaliadas)"]
      [(and (>= accuracy-rate 85.0) (> total-category-points 0))
       "🟢 Alta Autonomia e Domínio Fluente"]
      [(>= accuracy-rate 60.0)
       "🟡 Bom Ritmo de Aprendizagem (Consolidando)"]
      [else
       "🔴 Necessita Mediação Didática e Apoio Prático"]))

  (define cfg (load-teacher-config))

  (hasheq 'id-aluno student-id
          'nivel level
          'desc-nivel level-desc
          'pontos total-category-points
          'total total
          'sucessos successes
          'erros errors
          'sessoes sessions
          'avaliadas evaluated-count
          'taxa-acerto accuracy-rate
          'status-aproveitamento performance-status
          'mapa-cats cats-map
          'cfg cfg
          'mapa-arquivos files-map
          'contagem-dificuldades difficulty-counts
          'orientacao (get-didactic-guidance level accuracy-rate difficulty-counts evaluated-count total-category-points)))

(define (get-didactic-guidance level accuracy-rate difficulty-counts [evaluated-count 1] [points 0])
  (cond
    [(zero? evaluated-count)
     "Início de Jornada: Aprendiz ainda sem atividades práticas avaliadas registradas. Estimular a exploração dos primeiros exemplos e lições interativas no DrRacket."]
    [(< accuracy-rate 60.0)
     "Atenção prioritária: Estimular atividades em dupla ou propor desafios menores baseados nas lições do Nível 1."]
    [(and (>= accuracy-rate 85.0) (> points 0))
     (case level
       [(1) "Excelente evolução: O aprendiz demonstra autonomia funcional. Estimular desafios visuais e pequenas animações autorais."]
       [(2) "Fluência sólida: Praticar funções de validação e introduzir gradualmente o vocabulário oficial em inglês do HtDP."]
       [else "Domínio Pleno: Estudante apto a desenvolver projetos autorais e apoiar colegas como monitor/tutor voluntário!"])]
    [else
     (case level
       [(1) "Ritmo consistente: Revisar a sintaxe de 'defina' e cálculos antes de avançar para condicionais."]
       [(2) "Bom ritmo: O aprendiz está experimentando e corrigindo erros com apoio dos exemplos práticos. Reforçar conceitos de parâmetros e testes."]
       [else "Em transição avançada: Auxiliar na leitura dos contratos e mensagens de erro do DrRacket oficial."])]))

(define (generate-teacher-summary-text [student-filter #f])
  (define data (get-report-data student-filter #t))
  (define student-id (hash-ref data 'id-aluno))
  (define level-desc (hash-ref data 'desc-nivel))
  (define points (hash-ref data 'pontos))
  (define total (hash-ref data 'total))
  (define successes (hash-ref data 'sucessos))
  (define errors (hash-ref data 'erros))
  (define sessions (hash-ref data 'sessoes 0))
  (define evaluated (hash-ref data 'avaliadas (+ successes errors)))
  (define accuracy-rate (hash-ref data 'taxa-acerto))
  (define performance-status (hash-ref data 'status-aproveitamento))
  (define cats-map (hash-ref data 'mapa-cats))
  (define cfg (hash-ref data 'cfg))
  (define files-map (hash-ref data 'mapa-arquivos))
  (define difficulty-counts (hash-ref data 'contagem-dificuldades))
  (define guidance (hash-ref data 'orientacao))

  (define (format-cat label conquered? pts)
    (if conquered?
        (format "  ✅ ~a: Utilizada (+~a pt~a)" label pts (if (> pts 1) "s" ""))
        (format "  ⬜ ~a: Não utilizada ainda (0 / ~a pts)" label pts)))

  (define categories-lines
    (list
     (format-cat "Variáveis e Constantes" (hash-ref cats-map 'variavel #f) (hash-ref cfg 'pts_variavel 1))
     (format-cat "Declaração de Funções" (hash-ref cats-map 'funcao #f) (hash-ref cfg 'pts_funcao 2))
     (format-cat "Desvio Condicional ('se', 'escolha')" (hash-ref cats-map 'condicional #f) (hash-ref cfg 'pts_condicional 3))
     (format-cat "Repetição e Iteração ('repetir')" (hash-ref cats-map 'repeticao #f) (hash-ref cfg 'pts_repeticao 3))
     (format-cat "Testes Automatizados ('verificar-resultado')" (hash-ref cats-map 'teste #f) (hash-ref cfg 'pts_teste 2))))

  (define files-lines
    (if (zero? (hash-count files-map))
        (list "  Nenhum arquivo executado ainda.")
        (for/list ([(_ reg) (in-hash files-map)])
          (define name (hash-ref reg 'nome_arquivo "sem-titulo.rkt"))
          (define file-pts (hash-ref reg 'pontos 0))
          (define ts (format-timestamp-ptbr (hash-ref reg 'timestamp "")))
          (define details (hash-ref reg 'detalhes (hasheq)))
          (define v (if (hash-ref details 'tem_variavel #f) "Sim" "Não"))
          (define f (if (hash-ref details 'tem_funcao #f) "Sim" "Não"))
          (define c (if (hash-ref details 'tem_condicional #f) "Sim" "Não"))
          (define r (if (hash-ref details 'tem_repeticao #f) "Sim" "Não"))
          (define t-n (hash-ref details 'testes_aprovados 0))
          (format "  📁 ~a: ~a ponto(s) neste código [Atualizado: ~a]\n     • Construções: Var: ~a | Func: ~a | Cond: ~a | Loop: ~a | Testes aprovados: ~a"
                  name file-pts ts v f c r t-n))))

  (define difficulty-lines
    (if (zero? (hash-count difficulty-counts))
        (list "  Nenhuma dificuldade recorrente registrada até o momento!")
        (for/list ([(cat qtd) (in-hash difficulty-counts)])
          (format "  • ~a: ~a ocorrência(s)" cat qtd))))

  (format
   "====================================================\n  CASA DO IDOSO SUL - RELATÓRIO PEDAGÓGICO DOCENTE\n====================================================\n\nData de Atualização: ~a\n\nAprendiz: ~a\nNível Atual: ~a\nPontuação Global (Categorias Únicas): ~a pontos\nSessões de Acesso ao Ambiente: ~a sessão(ões)\nInstruções de Código Avaliadas: ~a (~a sucessos | ~a dúvidas/erros)\nTaxa de Aproveitamento Geral: ~a% [~a]\n\n--- Categorias de Instrução Conquistadas (Contabilizadas 1x) ---\n~a\n\n--- Histórico de Atividades por Arquivo (#lang adaptativa) ---\n~a\n\n--- Principais Pontos de Apoio Necessários ---\n~a\n\n\n--- Orientações Didáticas ao Mediador ---\n  ~a\n====================================================\n"
   (get-timestamp-ptbr)
   student-id
   level-desc
   points
   sessions
   evaluated
   successes
   errors
   (~r accuracy-rate #:precision '(= 1))
   performance-status
   (string-join categories-lines "\n")
   (string-join files-lines "\n\n")
   (string-join difficulty-lines "\n")
   guidance))

(define (insert-styled-line! editor txt [weight 'normal] [color (make-object color% 20 20 20)] [font-size 13] [family 'default] [italic? #f])
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

(define (render-colored-report! editor data)
  (send editor begin-edit-sequence)
  (send editor erase)

  (define student-id (hash-ref data 'id-aluno))
  (define level-desc (hash-ref data 'desc-nivel))
  (define points (hash-ref data 'pontos))
  (define total (hash-ref data 'total))
  (define successes (hash-ref data 'sucessos))
  (define errors (hash-ref data 'erros))
  (define sessions (hash-ref data 'sessoes 0))
  (define evaluated (hash-ref data 'avaliadas (+ successes errors)))
  (define accuracy-rate (hash-ref data 'taxa-acerto))
  (define performance-status (hash-ref data 'status-aproveitamento))
  (define cats-map (hash-ref data 'mapa-cats))
  (define cfg (hash-ref data 'cfg))
  (define files-map (hash-ref data 'mapa-arquivos))
  (define difficulty-counts (hash-ref data 'contagem-dificuldades))
  (define guidance (hash-ref data 'orientacao))

  (insert-styled-line! editor "CASA DO IDOSO SUL - CENTRO DE INCLUSÃO DIGITAL\n" 'bold (make-object color% 0 51 102) 16 'default)
  (insert-styled-line! editor "Relatório Pedagógico Individual e Acompanhamento de Aprendizagem\n" 'normal (make-object color% 70 70 70) 12 'default)
  (insert-styled-line! editor (format "Atualização: ~a\n\n" (get-timestamp-ptbr)) 'italic (make-object color% 100 100 100) 11 'default)

  (insert-styled-line! editor "1. PERFIL E DIAGNÓSTICO DO APRENDIZ\n" 'bold (make-object color% 0 0 0) 14 'default)
  (insert-styled-line! editor (format "  • Aprendiz Ativo: ~a\n" student-id) 'bold (make-object color% 30 30 30) 13 'default)
  (insert-styled-line! editor (format "  • Nível Pedagógico Atual: ~a\n" level-desc) 'normal (make-object color% 0 43 102) 13 'default)
  (insert-styled-line! editor (format "  • Pontuação Global Acumulada: ~a pontos (por categorias únicas)\n" points) 'bold (make-object color% 39 174 96) 13 'default)
  (insert-styled-line! editor (format "  • Sessões de Acesso ao Ambiente: ~a sessão(ões) registradas\n" sessions) 'normal (make-object color% 60 60 60) 12 'default)
  (insert-styled-line! editor (format "  • Instruções de Código Avaliadas: ~a total (~a sucessos | ~a dúvidas/erros)\n" evaluated successes errors) 'normal (make-object color% 60 60 60) 12 'default)
  (define evaluated-count (+ successes errors))
  (define status-color
    (cond
      [(zero? evaluated-count) (make-object color% 100 100 100)]
      [(>= accuracy-rate 70.0) (make-object color% 39 174 96)]
      [(>= accuracy-rate 50.0) (make-object color% 211 84 0)]
      [else (make-object color% 192 57 43)]))

  (insert-styled-line! editor (format "  • Taxa de Aproveitamento Geral: ~a% [~a]\n\n"
                                      (~r accuracy-rate #:precision '(= 1)) performance-status)
                       'bold
                       status-color
                       13
                       'default)

  (insert-styled-line! editor "2. CATEGORIAS DE INSTRUÇÃO CONQUISTADAS\n" 'bold (make-object color% 0 0 0) 14 'default)
  (insert-styled-line! editor "  (Cada categoria é contabilizada uma única vez para incentivar a diversidade do pensamento computacional)\n" 'italic (make-object color% 90 90 90) 11 'default)

  (define (draw-cat label conquered? pts)
    (if conquered?
        (insert-styled-line! editor (format "  ✅ ~a (+~a pt~a) - Conquistada!\n" label pts (if (> pts 1) "s" "")) 'bold (make-object color% 0 43 102) 12 'default)
        (insert-styled-line! editor (format "  ⬜ ~a (vale ~a pts) - Ainda não utilizada\n" label pts) 'normal (make-object color% 120 120 120) 12 'default)))

  (draw-cat "Variáveis e Constantes (defina ... como ...)" (hash-ref cats-map 'variavel #f) (hash-ref cfg 'pts_variavel 1))
  (draw-cat "Declaração de Funções (definir (f x) ...)" (hash-ref cats-map 'funcao #f) (hash-ref cfg 'pts_funcao 2))
  (draw-cat "Desvio Condicional (se / escolha)" (hash-ref cats-map 'condicional #f) (hash-ref cfg 'pts_condicional 3))
  (draw-cat "Repetição e Iteração (repetir N vezes)" (hash-ref cats-map 'repeticao #f) (hash-ref cfg 'pts_repeticao 3))
  (draw-cat "Testes Automatizados (verificar-resultado)" (hash-ref cats-map 'teste #f) (hash-ref cfg 'pts_teste 2))
  (insert-styled-line! editor "\n")

  (insert-styled-line! editor "3. HISTÓRICO DE ATIVIDADES POR CÓDIGO FONTE\n" 'bold (make-object color% 0 0 0) 14 'default)
  (if (zero? (hash-count files-map))
      (insert-styled-line! editor "  Nenhum código executado ainda neste perfil.\n\n" 'italic (make-object color% 100 100 100) 12 'default)
      (for ([(_ reg) (in-hash files-map)])
        (define name (hash-ref reg 'nome_arquivo "sem-titulo.rkt"))
        (define file-pts (hash-ref reg 'pontos 0))
        (define ts (format-timestamp-ptbr (hash-ref reg 'timestamp "")))
        (define details (hash-ref reg 'detalhes (hasheq)))
        (define v (if (hash-ref details 'tem_variavel #f) "Sim" "Não"))
        (define f (if (hash-ref details 'tem_funcao #f) "Sim" "Não"))
        (define c (if (hash-ref details 'tem_condicional #f) "Sim" "Não"))
        (define r (if (hash-ref details 'tem_repeticao #f) "Sim" "Não"))
        (define t-n (hash-ref details 'testes_aprovados 0))

        (insert-styled-line! editor (format "  📁 ~a: ~a ponto(s) neste arquivo  [Última execução: ~a]\n" name file-pts ts)
                             'bold (make-object color% 44 62 80) 12 'modern)
        (insert-styled-line! editor (format "     • Elementos: Variáveis: ~a | Funções: ~a | Condicionais: ~a | Repetições: ~a | Testes aprovados: ~a\n\n"
                                            v f c r t-n)
                             'normal (make-object color% 80 80 80) 11 'modern)))

  (insert-styled-line! editor "4. DIFICULDADES DETECTADAS E PONTOS DE ATENÇÃO\n" 'bold (make-object color% 0 0 0) 14 'default)
  (if (zero? (hash-count difficulty-counts))
      (insert-styled-line! editor "  Nenhuma dificuldade recorrente registrada. O aprendiz tem apresentado ótima desenvoltura!\n\n" 'italic (make-object color% 39 174 96) 12 'default)
      (begin
        (for ([(cat qtd) (in-hash difficulty-counts)])
          (insert-styled-line! editor (format "  ⚠️ ~a: ~a ocorrência(s)\n" cat qtd) 'normal (make-object color% 192 57 43) 12 'default))
        (insert-styled-line! editor "\n")))

  (insert-styled-line! editor "5. DIRETRIZES DIDÁTICAS PARA O MEDIADOR\n" 'bold (make-object color% 0 0 0) 14 'default)
  (insert-styled-line! editor (format "  👉 ~a\n\n" guidance) 'bold (make-object color% 0 51 102) 13 'default)

  (send editor set-position 0)
  (send editor end-edit-sequence))

(define (open-teacher-report-window [student-filter #f] [parent-window #f])
  (define students-list (list-available-students))
  (define active-student (or student-filter (get-current-student)))

  (define dlg
    (new dialog%
         [label "📊 Painel Pedagógico Docente - Acompanhamento do Aprendiz"]
         [parent parent-window]
         [width 880]
         [height 680]
         [style '(resize-border close-button)]))

  (define main-panel (new vertical-panel% [parent dlg] [border 12] [spacing 10]))

  (define control-panel
    (new horizontal-panel%
         [parent main-panel]
         [stretchable-height #f]
         [alignment '(left center)]
         [spacing 10]))

  (define text-editor (new text%))
  (define canvas-editor
    (new editor-canvas%
         [parent main-panel]
         [editor text-editor]
         [style '(auto-hscroll auto-vscroll)]))

  (define (refresh-report! target-id)
    (define report-data (get-report-data target-id #t))
    (render-colored-report! text-editor report-data))

  (define initial-idx
    (let ([idx (for/first ([(a i) (in-indexed students-list)]
                          #:when (equal? a active-student))
                 i)])
      (or idx 0)))

  (define student-choice
    (new choice%
         [parent control-panel]
         [label "Estudante: "]
         [choices (if (pair? students-list) students-list (list active-student))]
         [selection initial-idx]
         [callback (lambda (c e)
                     (define selected (send c get-string-selection))
                     (refresh-report! selected))]))

  (new button%
       [parent control-panel]
       [label "🔄 Atualizar Dados"]
       [callback (lambda (b e)
                   (refresh-report! (send student-choice get-string-selection)))])

  (new button%
       [parent control-panel]
       [label "📋 Copiar Relatório"]
       [callback (lambda (b e)
                   (define sel (send student-choice get-string-selection))
                   (define text
                     (let ([current-text (send text-editor get-text)])
                       (if (and (string? current-text) (non-empty-string? current-text))
                           current-text
                           (generate-teacher-summary-text sel))))
                   (send the-clipboard set-clipboard-string text (current-seconds))
                   (message-box "Relatório Copiado"
                                "O relatório pedagógico foi copiado para a área de transferência!"
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

  (refresh-report! active-student)
  (send dlg show #t))
