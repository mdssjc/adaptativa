#lang racket/base

(require rackunit
         racket/file
         racket/class
         racket/gui/base
         "../pedagogy/lessons-gui.rkt"
         "../pedagogy/config-gui.rkt"
         "../pedagogy/hints-gui.rkt"
         "../pedagogy/teacher-report.rkt"
         "../pedagogy/custom-content.rkt"
         "../tracker/logger.rkt"
         "../tracker/state.rkt"
         "../tracker/config.rkt")

(define TEST-DATA-DIR (make-temporary-file "adaptativa-gui-test-~a" 'directory))
(current-data-dir TEST-DATA-DIR)
(clear-profile-cache!)
(clear-config-cache!)
(clear-events-cache!)

(test-case "Verificação do Carregamento Dinâmico de Aulas da pasta /lessons"
  (define lessons (load-available-lessons))
  (check-true (>= (length lessons) 4) "Deve carregar pelo menos 4 aulas da pasta lessons")

  (define lesson1 (car lessons))
  (check-equal? (hash-ref lesson1 'aula) 1)
  (check-equal? (hash-ref lesson1 'nivel) 1)
  (check-true (regexp-match? #rx"Primeiros Passos" (hash-ref lesson1 'titulo)))
  (check-true (regexp-match? #rx"🌱 Aula 01:" (hash-ref lesson1 'label)))

  (define lesson2 (cadr lessons))
  (check-equal? (hash-ref lesson2 'aula) 2)
  (check-equal? (hash-ref lesson2 'nivel) 1)

  (define lesson3 (caddr lessons))
  (check-equal? (hash-ref lesson3 'aula) 3)
  (check-equal? (hash-ref lesson3 'nivel) 1)
  (check-true (regexp-match? #rx"🌱 Aula 03:" (hash-ref lesson3 'label)))

  (define lesson4 (cadddr lessons))
  (check-equal? (hash-ref lesson4 'aula) 4)
  (check-equal? (hash-ref lesson4 'nivel) 2)
  (check-true (regexp-match? #rx"🌿 Aula 04:" (hash-ref lesson4 'label)))

  (define codes-lesson1 (extract-lesson-code (file->string (hash-ref lesson1 'caminho))))
  (check-true (string? codes-lesson1))
  (check-true (regexp-match? #rx"defina" codes-lesson1))
  (check-true (regexp-match? #rx"mostrar" codes-lesson1)))

(test-case "Verificação da Renderização de Aula sem Efeito Cumulativo de Tamanho de Fonte"
  (define ed (new text%))
  (define test-content
    "# Título H1\n\nTexto explicativo 1.\n\n## Subtítulo H2\n\n```racket\n(defina x 10)\n```\n\nTexto explicativo 2.\n- Passo 1: Fazer algo\n- Passo 2: Fazer outra coisa\n\nTexto final.\n\n## 💡 Dica ao Mediador\nEstimule o aprendiz com paciência.")
  (render-colored-lesson! ed test-content)
  (check-true (> (send ed last-position) 50))
  (define snip-start (send ed find-snip 0 'after))
  (define style-start (send snip-start get-style))
  (define font-start (send style-start get-font))
  (check-true (>= (send font-start get-point-size) 16) "H1 deve ter fonte de destaque >= 16pt")
  (check-equal? (send font-start get-weight) 'bold "H1 deve ser negrito")
  (check-equal? (send (send style-start get-foreground) red) 0 "H1 deve ser preto (red=0)")

  (define snip-mid (send ed find-snip 40 'after))
  (when snip-mid
    (define font-mid (send (send snip-mid get-style) get-font))
    (check-true (<= (send font-mid get-point-size) 20) "Texto no meio não deve sofrer efeito cumulativo (< 20pt)"))

  (define pos-mediator (send ed find-string "Dica ao Mediador"))
  (check-true (number? pos-mediator) "Deve encontrar a seção de Dica ao Mediador")
  (define snip-mediator (send ed find-snip pos-mediator 'after))
  (define style-mediator (send snip-mediator get-style))
  (check-true (> (send (send style-mediator get-foreground) red) 150) "Dica ao mediador deve ser vermelha (red > 150)")

  (define pos-code (send ed find-string "(defina x 10)"))
  (check-true (number? pos-code) "Deve encontrar o bloco de código")
  (define snip-code (send ed find-snip pos-code 'after))
  (define style-code (send snip-code get-style))
  (define color-code (send style-code get-foreground))
  (check-equal? (send color-code red) 51 "Código deve ser cinza escuro #333333 (red=51)")
  (check-equal? (send color-code green) 51 "Código deve ser cinza escuro #333333 (green=51)")
  (check-equal? (send color-code blue) 51 "Código deve ser cinza escuro #333333 (blue=51)"))

(test-case "Verificação da Renderização de Tabelas Markdown na Janela de Aulas"
  (define ed (new text%))
  (define table-content
    "# Aula com Tabela\n\n| Item | Descrição | Valor |\n| :--- | :--- | :--- |\n| **A** | `Primeiro item` | 10 |\n| **B** | `Segundo item` | 20 |\n\nTexto após tabela.")
  (render-colored-lesson! ed table-content)
  (define rendered-text (send ed get-text))

  (check-false (regexp-match? #rx"\\| :--- \\|" rendered-text)
               "Não deve exibir separadores crus de markdown | :--- |")
  (check-false (regexp-match? #rx"\\| \\*\\*A\\*\\* \\|" rendered-text)
               "Não deve exibir células com marcações brutas de asteriscos")

  (check-true (regexp-match? #rx"┌" rendered-text) "Deve conter borda superior de tabela")
  (check-true (regexp-match? #rx"├" rendered-text) "Deve conter divisor entre cabeçalho e dados")
  (check-true (regexp-match? #rx"└" rendered-text) "Deve conter borda inferior de tabela")
  (check-true (regexp-match? #rx"│ Item" rendered-text) "Deve conter cabeçalho limpo e alinhado")
  (check-true (regexp-match? #rx"│ Primeiro item" rendered-text) "Deve conter texto limpo sem crases")

  (define path-lesson7 (build-path (get-default-lessons-dir) "09-aula-autonomia-htdp-bilingue.md"))
  (define content-lesson7 (file->string path-lesson7))
  (render-colored-lesson! ed content-lesson7)
  (define text-lesson7 (send ed get-text))
  (check-false (regexp-match? #rx"\\| :--- \\| :--- \\| :--- \\|" text-lesson7)
               "Aula bilíngue não deve conter a linha crua de separador markdown")
  (check-true (regexp-match? #rx"│ Conceito" text-lesson7)
               "Aula bilíngue deve conter coluna Conceito renderizada em tabela")
  (check-true (regexp-match? #rx"│ Definições" text-lesson7)
               "Aula bilíngue deve conter linha Definições renderizada")
  (check-true (regexp-match? #rx"\\(definir \\.\\.\\.\\) / \\(defina \\.\\.\\. como \\.\\.\\.\\)" text-lesson7)
               "Aula bilíngue deve conter equivalência em português limpa sem crases")
  (check-true (regexp-match? #rx"\\(define \\.\\.\\.\\)" text-lesson7)
               "Aula bilíngue deve conter equivalência em inglês HtDP oficial"))

(test-case "Verificação da Janela Unificada de Configurações, PIN e Gestão de Alunos"
  (define orig-student (get-current-student))
  (define orig-cfg (load-teacher-config))

  (save-teacher-pin! "9876")
  (check-true (teacher-pin-registered?) "PIN deve estar cadastrado")
  (check-true (verify-teacher-pin "9876") "PIN correto deve ser validado")
  (check-false (verify-teacher-pin "0000") "PIN errado deve ser rejeitado")

  (register-new-student! "aluno_teste_gestao")
  (check-equal? (get-current-student) "aluno_teste_gestao")
  (check-not-false (member "aluno_teste_gestao" (list-all-students)))

  (add-student-points! "aluno_teste_gestao" 10 'teste "Pontos de teste")
  (check-equal? (get-student-points "aluno_teste_gestao") 10)
  (reset-student-progress! "aluno_teste_gestao")
  (check-equal? (get-student-points "aluno_teste_gestao") 0 "Pontuação deve zerar após reiniciar progresso")

  (remove-student! "aluno_teste_gestao")
  (check-false (member "aluno_teste_gestao" (list-all-students)) "Aluno removido não deve constar na listagem")

  (set-current-student! orig-student)
  (save-teacher-config! orig-cfg))

(test-case "Verificação da Janela de Relatório Docente e Listagem de Alunos"
  (define students (list-available-students))
  (check-true (pair? students) "Deve listar pelo menos o aluno ativo ou perfis salvos")
  (check-not-false (member (get-current-student) students) "O aluno atual deve constar na listagem de alunos")

  (define summary (generate-teacher-summary-text))
  (check-true (string? summary))
  (check-true (regexp-match? #rx"CASA DO IDOSO SUL" summary))
  (check-true (regexp-match? #rx"Categorias de Instrução Conquistadas" summary))

  (define ed-rep (new text%))
  (define dummy-data
    (hasheq 'id-aluno "aluno_teste_cores"
            'nivel 2
            'desc-nivel "🌿 Nível 2"
            'pontos 5
            'total 10
            'sucessos 8
            'erros 2
            'taxa-acerto 80.0
            'status-aproveitamento "🟡 Bom Ritmo"
            'mapa-cats (hasheq 'variavel #t 'funcao #f)
            'cfg (load-teacher-config)
            'mapa-arquivos (hasheq)
            'contagem-dificuldades (hash "variavel-indefinida" 2)
            'orientacao "Apoiar com paciência."))
  (render-colored-report! ed-rep dummy-data)
  (check-true (> (send ed-rep last-position) 100))

  (define pos-sec (send ed-rep find-string "1. PERFIL E DIAGNÓSTICO DO APRENDIZ"))
  (check-true (number? pos-sec))
  (define snip-sec (send ed-rep find-snip pos-sec 'after))
  (define font-sec (send (send snip-sec get-style) get-font))
  (check-equal? (send font-sec get-weight) 'bold "Título de seção do relatório deve ser negrito")
  (check-equal? (send (send (send snip-sec get-style) get-foreground) red) 0 "Título de seção deve ser preto")

  (define pos-check (send ed-rep find-string "Conquistada"))
  (check-true (number? pos-check))
  (define snip-check (send ed-rep find-snip pos-check 'after))
  (define color-check (send (send snip-check get-style) get-foreground))
  (check-equal? (send color-check blue) 102 "Check conquistado deve ser azul escuro #002b66 (blue=102)")

  (define pos-err (send ed-rep find-string "variavel-indefinida"))
  (check-true (number? pos-err))
  (define snip-err (send ed-rep find-snip pos-err 'after))
  (define color-err (send (send snip-err get-style) get-foreground))
  (check-equal? (send color-err red) 192 "Erro na listagem deve ser vermelho #c0392b (red=192)")

  (define text-rep (send ed-rep get-text))
  (check-true (regexp-match? #rx"Atualização:" text-rep) "Deve conter cabeçalho de Atualização")
  (check-false (regexp-match? #rx"Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday" text-rep)
               "Não deve conter dias em inglês")
  (check-false (regexp-match? #rx"January|February|March|April|May|June|July|August|September|October|November|December" text-rep)
               "Não deve conter meses em inglês")
  (check-true (regexp-match? #rx"Domingo|Segunda-feira|Terça-feira|Quarta-feira|Quinta-feira|Sexta-feira|Sábado" text-rep)
              "Deve exibir data com dia da semana em português")

  (define ed-rep-zero (new text%))
  (define zero-data
    (hasheq 'id-aluno "aluno_zero_pontos"
            'nivel 1
            'desc-nivel "🌱 Nível 1"
            'pontos 0
            'total 5
            'sucessos 0
            'erros 0
            'taxa-acerto 0.0
            'status-aproveitamento "⚪ Inicial (Aguardando Atividades Avaliadas)"
            'mapa-cats (hasheq)
            'cfg (load-teacher-config)
            'mapa-arquivos (hasheq)
            'contagem-dificuldades (hash)
            'orientacao "Início de Jornada."))
  (render-colored-report! ed-rep-zero zero-data)
  (define text-rep-zero (send ed-rep-zero get-text))
  (check-true (regexp-match? #rx"Taxa de Aproveitamento Geral: 0\\.0%" text-rep-zero)
              "Aluno com 0 atividades deve ter 0.0% de aproveitamento")
  (check-true (regexp-match? #rx"Inicial" text-rep-zero)
              "Aluno sem execuções avaliadas deve exibir status inicial")
  (define pos-taxa-zero (send ed-rep-zero find-string "Taxa de Aproveitamento Geral"))
  (define snip-taxa-zero (send ed-rep-zero find-snip pos-taxa-zero 'after))
  (define color-taxa-zero (send (send snip-taxa-zero get-style) get-foreground))
  (check-equal? (send color-taxa-zero red) 100 "Status inicial deve ser renderizado em cinza neutro (red=100)"))

(test-case "Verificação da Gestão de Aulas e Exemplos Personalizados pelo Docente"
  (define tmp-lesson (make-temporary-file "temp-aula-~a.md"))
  (display-to-file
   "# Aula 99: Projeto Personalizado do Professor\n;; @nivel: 1\n;; @aula: 99\n\nTexto de aula customizada.\n```racket\n(defina especial 123)\n```\n"
   tmp-lesson
   #:exists 'replace)

  (define custom-lesson-name "aula-99-docente.md")
  (add-custom-lesson! tmp-lesson custom-lesson-name)
  (check-true (custom-lesson? custom-lesson-name))
  (check-not-false (member custom-lesson-name (list-custom-lessons)))

  (define lessons-with-custom (load-available-lessons #t))
  (define found-lesson
    (findf (lambda (a) (string=? (hash-ref a 'arquivo) custom-lesson-name)) lessons-with-custom))
  (check-not-false found-lesson "A nova aula adicionada deve estar presente nas aulas disponíveis")
  (check-equal? (hash-ref found-lesson 'aula) 99)
  (check-equal? (hash-ref found-lesson 'nivel) 1)
  (check-true (hash-ref found-lesson 'customizada?))
  (check-true (regexp-match? #rx"✏️ \\[Docente\\]" (hash-ref found-lesson 'label)))

  (define read-content (read-lesson-content custom-lesson-name))
  (check-true (regexp-match? #rx"Projeto Personalizado do Professor" read-content))

  (check-true (remove-custom-lesson! custom-lesson-name))
  (check-false (custom-lesson? custom-lesson-name))
  (define lessons-after-removal (load-available-lessons #t))
  (check-true (>= (length lessons-after-removal) 4) "As 4 aulas padrão da instalação devem continuar intactas")

  (define tmp-ex (make-temporary-file "temp-exemplo-~a.rkt"))
  (display-to-file
   "#lang adaptativa\n;; @nivel: 2\n;; @licao: 88\n;; @titulo: Desafio do Professor\n\n(defina bonus 500)\n"
   tmp-ex
   #:exists 'replace)

  (define custom-ex-name "exemplo-88-docente.rkt")
  (add-custom-example! tmp-ex custom-ex-name)
  (check-true (custom-example? custom-ex-name))
  (check-not-false (member custom-ex-name (list-custom-examples)))

  (define examples-with-custom (load-available-examples #t))
  (define found-ex
    (findf (lambda (e) (string=? (hash-ref e 'arquivo) custom-ex-name)) examples-with-custom))
  (check-not-false found-ex "O novo exemplo deve constar nos exemplos disponíveis")
  (check-equal? (hash-ref found-ex 'nivel) 2)
  (check-equal? (hash-ref found-ex 'licao) 88)
  (check-true (hash-ref found-ex 'customizado?))
  (check-true (regexp-match? #rx"✏️ \\[Docente\\]" (hash-ref found-ex 'label)))

  (define read-code (read-example-code custom-ex-name))
  (check-true (regexp-match? #rx"bonus 500" read-code))

  (check-true (remove-custom-example! custom-ex-name))
  (check-false (custom-example? custom-ex-name))
  (define examples-after-removal (load-available-examples #t))
  (check-true (>= (length examples-after-removal) 4) "Os exemplos padrão da instalação devem continuar intactos")

  (delete-file tmp-lesson)
  (delete-file tmp-ex))

(clear-profile-cache!)
(clear-config-cache!)
(clear-events-cache!)
(with-handlers ([exn:fail? void])
  (delete-directory/files TEST-DATA-DIR))
