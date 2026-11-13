#lang scribble/manual

@require[@for-label[adaptativa]]

@title{Linguagem Adaptativa}
@author{Marcelo dos Santos}

@defmodulelang[adaptativa]

A linguagem @bold{#lang adaptativa} é um ambiente educacional em Português voltado para o
ensino de pensamento computacional, matemática e lógica de programação para idosos e iniciantes no DrRacket.

Projetada com uma abordagem pedagógica inclusiva e progressiva desenvolvida no contexto da
Casa do Idoso Sul, a linguagem oferece mensagens de erro amigáveis, comandos em linguagem natural,
progressão adaptativa em três níveis e ferramentas de apoio pedagógico (pontuação automática,
dicas interativas, roteiros de aula e relatório docente) integradas à interface do DrRacket.

@table-of-contents[]

@section{Identificação e Autoria}

@defform[(aluno nome-string)]{
  Registra o nome do aprendiz no início do arquivo. É utilizado pelo sistema pedagógico
  para vincular o histórico de conquistas e aprendizado ao perfil do aluno.

  @racketblock[
    (aluno "Dona Maria")
  ]
}

@section{Variáveis, Constantes e Memória}

@defform[(defina nome como valor)]{
  Forma amigável de atribuição direta para iniciantes. Associa um valor a um nome de variável.

  @racketblock[
    (defina idade como 68)
    (defina cidade como "São José dos Campos")
    (defina raio como 15)
  ]
}

@defform[(definir id expr)]{
  Cria uma constante ou função canônica.
  
  Também pode ser utilizado na forma de declaração de funções:
  @racketblock[
    (definir preco-total 150)

    (definir (dobro x)
      (* x 2))

    (definir (saudacao nome)
      (juntar-texto "Olá, " nome "! Seja bem-vindo(a)."))
  ]
}

@defform[(definir-registro nome (campo ...))]{
  Cria uma estrutura de dados com campos nomeados, equivalente a @tt{define-struct}.
  Gera automaticamente o construtor @tt{make-nome}, o predicado @tt{nome?} e os seletores para cada campo.

  @racketblock[
    (definir-registro ponto (x y))
    (defina meu-ponto como (make-ponto 10 20))
    (mostrar (ponto-x meu-ponto))
  ]
}

@section{Entrada e Saída de Dados}

@subsection{Exibição no Terminal}

@defproc[(mostrar [v any/c] ...) void?]{
  Exibe um ou mais valores na janela de interações do DrRacket, seguidos de quebra de linha.
  Aceita números, textos, booleanos e listas.

  @racketblock[
    (mostrar "Olá, mundo!")
    (mostrar "Idade:" 72 "anos")
    (mostrar "Resultado do cálculo:" (+ 10 20))
  ]
}

@subsection{Leitura pelo Terminal}

@defproc[(ler-linha [mensagem (or/c string? boolean?) #f]) string?]{
  Lê uma linha inteira digitada pelo aprendiz no terminal do DrRacket (até pressionar Enter).
  Opcionalmente, exibe @racket[mensagem] antes da leitura.

  @racketblock[
    (defina nome como (ler-linha "Digite seu nome: "))
    (mostrar "Prazer em conhecê-lo(a), " nome)
  ]
}

@defproc[(ler-texto [mensagem (or/c string? boolean?) #f]) string?]{
  Sinônimo amigável de @racket[ler-linha]. Lê um texto digitado pelo aprendiz no terminal.

  @racketblock[
    (defina cidade como (ler-texto "Qual é a sua cidade? "))
  ]
}

@defproc[(ler-numero [mensagem (or/c string? boolean?) #f]) number?]{
  Lê um número digitado pelo aprendiz no terminal. Caso o texto digitado não seja um número
  válido, avisa o aprendiz e solicita novamente até receber um número válido (retorna @racket[0] em fim de entrada).

  @racketblock[
    (defina ano como (ler-numero "Digite o ano de nascimento: "))
    (mostrar "Idade aproximada:" (- 2026 ano))
  ]
}

@subsection{Caixas de Diálogo Gráficas (Popup)}

@defproc[(pedir-texto [pergunta string? "Digite um texto:"] [titulo string? "Entrada de Texto"]) string?]{
  Abre uma janela gráfica solicitando um texto ao usuário. Retorna uma string vazia (@racket[""]) se a operação for cancelada.

  @racketblock[
    (defina fruta-favorita como (pedir-texto "Qual é a sua fruta favorita?"))
    (mostrar "Fruta escolhida:" fruta-favorita)
  ]
}

@defproc[(pedir-numero [pergunta string? "Digite um número:"] [titulo string? "Entrada Numérica"]) number?]{
  Abre uma janela gráfica solicitando um número ao usuário. Valida a entrada automaticamente em loop até receber um número válido, ou retorna @racket[0] se a janela for cancelada.

  @racketblock[
    (defina quantidade como (pedir-numero "Quantos passos a tartaruga deve dar?"))
    (avancar quantidade)
  ]
}

@defproc[(esperar [segundos real?]) void?]{
  Pausa a execução do programa pelo número de segundos especificado (útil para animações e temporizações).

  @racketblock[
    (mostrar "Preparar...")
    (esperar 1)
    (mostrar "Apontar...")
    (esperar 1)
    (mostrar "Fogo!")
  ]
}

@section{Decisão e Lógica Condicional}

@defform[(se condicao entao-expr senao-expr)]{
  Avalia @racket[condicao]. Se for verdadeira (@racket[#true]), executa e retorna @racket[entao-expr];
  caso contrário, executa e retorna @racket[senao-expr].

  @racketblock[
    (definir (classificar-idade idade)
      (se (>= idade 60)
          "Melhor Idade (Prioridade e Respeito)"
          "Jovem Aprendiz"))

    (mostrar (classificar-idade 65))
  ]
}

@defform[(escolha [condicao resultado] ... [senao resultado-padrao])]{
  Permite avaliar múltiplos caminhos alternativos sequencialmente (equivalente a @tt{cond}).
  O ramo @racket[senao] é executado caso nenhuma condição anterior seja atendida.

  @racketblock[
    (definir (situacao-nota nota)
      (escolha
       [(>= nota 7.0) "Aprovado com Louvor!"]
       [(>= nota 5.0) "Em Recuperação"]
       [senao "Precisa de Apoio Pedagógico"]))

    (mostrar (situacao-nota 8.5))
  ]
}

@subsection{Operadores de Comparação e Predicados}

Podem ser utilizados tanto os nomes em português (@racket[igual?], @racket[maior?], @racket[e], @racket[ou]) quanto os símbolos clássicos (@racket[=], @racket[>], @racket[<], @racket[and], @racket[or]).

@defproc[(= [a number?] [b number?] ...) boolean?]{
  Compara se dois ou mais números são iguais.
  @racketblock[
    (= 10 (+ 5 5)) ; resulta em #true
  ]
}

@defproc[(igual? [a any/c] [b any/c]) boolean?]{
  Verifica se dois valores quaisquer são iguais (textos, números, símbolos ou figuras).
  @racketblock[
    (igual? "casa" "casa") ; resulta em #true
    (igual? 100 100)       ; resulta em #true
  ]
}

@defproc[(diferente? [a any/c] [b any/c]) boolean?]{
  Verifica se dois valores são diferentes.
  @racketblock[
    (diferente? "azul" "verde") ; resulta em #true
  ]
}

@defproc[(> [a real?] [b real?] ...) boolean?]{
  Verifica se os números estão em ordem estritamente decrescente.
  @racketblock[
    (> 10 5) ; resulta em #true
  ]
}

@defproc[(maior? [a real?] [b real?]) boolean?]{
  Verifica se @racket[a] é estritamente maior que @racket[b].
  @racketblock[
    (maior? 15 10) ; resulta em #true
  ]
}

@defproc[(< [a real?] [b real?] ...) boolean?]{
  Verifica se os números estão em ordem estritamente crescente.
  @racketblock[
    (< 3 7) ; resulta em #true
  ]
}

@defproc[(menor? [a real?] [b real?]) boolean?]{
  Verifica se @racket[a] é estritamente menor que @racket[b].
  @racketblock[
    (menor? 4 9) ; resulta em #true
  ]
}

@defproc[(>= [a real?] [b real?] ...) boolean?]{
  Verifica se os números estão em ordem decrescente ou iguais.
  @racketblock[
    (>= 10 10) ; resulta em #true
  ]
}

@defproc[(maior-ou-igual? [a real?] [b real?]) boolean?]{
  Verifica se @racket[a] é maior ou igual a @racket[b].
  @racketblock[
    (maior-ou-igual? 60 60) ; resulta em #true
  ]
}

@defproc[(<= [a real?] [b real?] ...) boolean?]{
  Verifica se os números estão em ordem crescente ou iguais.
  @racketblock[
    (<= 5 8) ; resulta em #true
  ]
}

@defproc[(menor-ou-igual? [a real?] [b real?]) boolean?]{
  Verifica se @racket[a] é menor ou igual a @racket[b].
  @racketblock[
    (menor-ou-igual? 15 20) ; resulta em #true
  ]
}

@defform[(e expr ...)]{
  Operador lógico E (com avaliação em curto-circuito). Retorna verdadeiro apenas se todas as expressões fornecidas forem verdadeiras.
  @racketblock[
    (e (maior? 10 5) (menor? 10 20)) ; resulta em #true
  ]
}

@defform[(ou expr ...)]{
  Operador lógico OU (com avaliação em curto-circuito). Retorna verdadeiro se ao menos uma das expressões for verdadeira.
  @racketblock[
    (ou (igual? "sol" "chuva") (igual? "sol" "sol")) ; resulta em #true
  ]
}

@defproc[(nao [expr boolean?]) boolean?]{
  Negação lógica. Inverte o valor booleano (retorna falso se o argumento for verdadeiro, e verdadeiro se for falso).
  @racketblock[
    (nao falso)      ; resulta em #true
    (nao verdadeiro) ; resulta em #false
  ]
}

@defproc[(e-par? [n integer?]) boolean?]{
  Retorna verdadeiro se o número inteiro for par.
  @racketblock[
    (e-par? 12) ; resulta em #true
    (e-par? 7)  ; resulta em #false
  ]
}

@defproc[(e-impar? [n integer?]) boolean?]{
  Retorna verdadeiro se o número inteiro for ímpar.
  @racketblock[
    (e-impar? 15) ; resulta em #true
  ]
}

@defproc[(e-positivo? [n real?]) boolean?]{
  Retorna verdadeiro se o número for maior que zero.
  @racketblock[
    (e-positivo? 5)  ; resulta em #true
    (e-positivo? -3) ; resulta em #false
  ]
}

@defproc[(e-negativo? [n real?]) boolean?]{
  Retorna verdadeiro se o número for menor que zero.
  @racketblock[
    (e-negativo? -8) ; resulta em #true
  ]
}

@defproc[(e-zero? [n number?]) boolean?]{
  Retorna verdadeiro se o valor for exatamente zero.
  @racketblock[
    (e-zero? 0) ; resulta em #true
  ]
}

@section{Repetição e Iteração}

@defform[(repetir n vezes corpo ...)]{
  Executa o bloco de instruções @racket[corpo ...] exatamente @racket[n] vezes.
  É ideal para desenhar figuras repetidas, polígonos com a tartaruga ou executar tarefas sequenciais.

  @racketblock[
    (repetir 4 vezes
      (avancar 100)
      (girar-direita 90))
  ]
}

@section{Listas e Coleções}

@defproc[(lista [item any/c] ...) list?]{
  Cria uma lista contendo os itens fornecidos em sequência.
  @racketblock[
    (defina compras como (lista "maçã" "banana" "laranja"))
    (defina notas como (lista 8 9 10))
  ]
}

@defproc[(primeiro [lst list?]) any/c]{
  Retorna o primeiro elemento de uma lista não-vazia.
  @racketblock[
    (primeiro (lista "ouro" "prata" "bronze")) ; resulta em "ouro"
  ]
}

@defproc[(resto [lst list?]) list?]{
  Retorna uma nova lista contendo todos os elementos exceto o primeiro.
  @racketblock[
    (resto (lista 1 2 3 4)) ; resulta em (list 2 3 4)
  ]
}

@defproc[(vazia? [lst any/c]) boolean?]{
  Verifica se a lista fornecida não contém elementos.
  @racketblock[
    (vazia? (lista))        ; resulta em #true
    (vazia? (lista 10 20))  ; resulta em #false
  ]
}

@defproc[(tamanho-lista [lst list?]) natural-number/c]{
  Retorna a quantidade de elementos presentes na lista.
  @racketblock[
    (tamanho-lista (lista "A" "B" "C")) ; resulta em 3
  ]
}

@defproc[(juntar-listas [lst list?] ...) list?]{
  Concatena duas ou mais listas em uma única lista combinada.
  @racketblock[
    (juntar-listas (lista 1 2) (lista 3 4)) ; resulta em (list 1 2 3 4)
  ]
}

@defproc[(inverter-lista [lst list?]) list?]{
  Retorna uma nova lista com todos os elementos na ordem inversa.
  @racketblock[
    (inverter-lista (lista 1 2 3)) ; resulta em (list 3 2 1)
  ]
}

@section{Operações Matemáticas e Aritmética}

As operações matemáticas podem ser escritas tanto com os símbolos tradicionais (@racket[+], @racket[-], @racket[*], @racket[/]) quanto com as palavras em português (@racket[somar], @racket[subtrair], @racket[multiplicar], @racket[dividir]).

@defproc[(+ [n number?] ...) number?]{
  Soma dois ou mais números.
  @racketblock[
    (+ 10 5)   ; resulta em 15
    (+ 1 2 3)  ; resulta em 6
  ]
}

@defproc[(somar [n number?] ...) number?]{
  Sinônimo amigável em português para a operação de soma @racket[+].
  @racketblock[
    (somar 10 20)     ; resulta em 30
    (somar 5 15 25)   ; resulta em 45
  ]
}

@defproc[(- [n number?] [m number?] ...) number?]{
  Subtrai os valores subsequentes do primeiro número. Se fornecido apenas um número, inverte o sinal (negação).
  @racketblock[
    (- 20 8) ; resulta em 12
    (- 5)    ; resulta em -5
  ]
}

@defproc[(subtrair [n number?] [m number?] ...) number?]{
  Sinônimo amigável em português para a operação de subtração @racket[-].
  @racketblock[
    (subtrair 50 15) ; resulta em 35
  ]
}

@defproc[(* [n number?] ...) number?]{
  Multiplica dois ou mais números.
  @racketblock[
    (* 4 5)   ; resulta em 20
    (* 2 3 4) ; resulta em 24
  ]
}

@defproc[(multiplicar [n number?] ...) number?]{
  Sinônimo amigável em português para a operação de multiplicação @racket[*].
  @racketblock[
    (multiplicar 6 7) ; resulta em 42
  ]
}

@defproc[(/ [n number?] [d number?] ...) number?]{
  Divide o primeiro número pelos seguintes. Lembre-se que o divisor não pode ser zero.
  @racketblock[
    (/ 10 2) ; resulta em 5
  ]
}

@defproc[(dividir [n number?] [d number?] ...) number?]{
  Sinônimo amigável em português para a operação de divisão @racket[/].
  @racketblock[
    (dividir 100 4) ; resulta em 25
  ]
}

@defproc[(abs [n real?]) real?]{
  Retorna o valor absoluto (módulo) do número, tornando-o sempre positivo.
  @racketblock[
    (abs -15) ; resulta em 15
  ]
}

@defproc[(absoluto [n real?]) real?]{
  Sinônimo amigável de @racket[abs].
  @racketblock[
    (absoluto -42) ; resulta em 42
  ]
}

@defproc[(max [n real?] ...) real?]{
  Retorna o maior valor entre os números fornecidos.
  @racketblock[
    (max 5 18 3 12) ; resulta em 18
  ]
}

@defproc[(maximo [n real?] ...) real?]{
  Sinônimo amigável de @racket[max].
  @racketblock[
    (maximo 10 25 7) ; resulta em 25
  ]
}

@defproc[(min [n real?] ...) real?]{
  Retorna o menor valor entre os números fornecidos.
  @racketblock[
    (min 8 3 15) ; resulta em 3
  ]
}

@defproc[(minimo [n real?] ...) real?]{
  Sinônimo amigável de @racket[min].
  @racketblock[
    (minimo 50 20 80) ; resulta em 20
  ]
}

@defproc[(quadrado [n number?]) number?]{
  Calcula o quadrado de um número (o número multiplicado por ele mesmo).
  @racketblock[
    (quadrado 8) ; resulta em 64
    (quadrado 5) ; resulta em 25
  ]
}

@defproc[(potencia [base number?] [expoente number?]) number?]{
  Calcula a potência da base elevada ao expoente.
  @racketblock[
    (potencia 2 3)  ; resulta em 8
    (potencia 10 3) ; resulta em 1000
  ]
}

@defproc[(quociente [n integer?] [m integer?]) integer?]{
  Calcula o quociente inteiro da divisão de @racket[n] por @racket[m], descartando o resto.
  @racketblock[
    (quociente 14 3) ; resulta em 4
    (quociente 20 6) ; resulta em 3
  ]
}

@defproc[(raiz-quadrada [n (and/c real? (not/c negative?))]) real?]{
  Calcula a raiz quadrada exata ou aproximada de um número positivo ou zero.
  @racketblock[
    (raiz-quadrada 49) ; resulta em 7
    (raiz-quadrada 2)  ; resulta em 1.4142...
  ]
}

@defproc[(arredondar [n real?]) integer?]{
  Arredonda um número com casas decimais para o inteiro mais próximo.
  @racketblock[
    (arredondar 4.3) ; resulta em 4
    (arredondar 4.8) ; resulta em 5
  ]
}

@defproc[(resto-divisao [n integer?] [d integer?]) integer?]{
  Calcula o resto da divisão inteira de @racket[n] por @racket[d] (equivalente a @racket[remainder]).
  @racketblock[
    (resto-divisao 10 3) ; resulta em 1
    (resto-divisao 14 5) ; resulta em 4
  ]
}

@defproc[(sortear-numero [min integer?] [max integer?]) integer?]{
  Sorteia um número inteiro aleatório entre @racket[min] e @racket[max] (inclusive).
  @racketblock[
    (defina dado como (sortear-numero 1 6))
    (mostrar "Número sorteado no dado:" dado)
  ]
}

@defthing[pi real?]{
  A constante matemática Pi (@tt{3.14159...}), útil para cálculos geométricos com círculos e circunferências.
  @racketblock[
    (definir (area-circulo raio)
      (* pi (quadrado raio)))
  ]
}

@defthing[verdadeiro boolean?]{
  Constante lógica verdadeira (equivalente a @racket[#true]).
  @racketblock[
    (defina usuario-ativo como verdadeiro)
  ]
}

@defthing[falso boolean?]{
  Constante lógica falsa (equivalente a @racket[#false]).
  @racketblock[
    (defina tarefa-concluida como falso)
  ]
}

@section{Textos e Manipulação de Caracteres}

@defproc[(juntar-texto [v any/c] ...) string?]{
  Concatena múltiplos textos, números ou valores em uma única cadeia de caracteres (@tt{string}).
  Converte valores não-texto automaticamente para sua representação legível.

  @racketblock[
    (juntar-texto "Olá, " "Dona " "Maria" "!") ; resulta em "Olá, Dona Maria!"
    (juntar-texto "Total de pontos: " 42)      ; resulta em "Total de pontos: 42"
  ]
}

@defproc[(tamanho-texto [txt string?]) natural-number/c]{
  Retorna o número de caracteres presentes no texto (incluindo espaços e pontuações).

  @racketblock[
    (tamanho-texto "Racket")        ; resulta em 6
    (tamanho-texto "Casa do Idoso") ; resulta em 13
  ]
}

@defproc[(texto->numero [txt string?]) (or/c number? boolean?)]{
  Converte um texto contendo dígitos numéricos em um número real ou inteiro. Retorna @racket[#false] caso o texto não seja um número válido.

  @racketblock[
    (texto->numero "123")  ; resulta em 123
    (texto->numero "45.5") ; resulta em 45.5
    (texto->numero "olá")  ; resulta em #false
  ]
}

@defproc[(numero->texto [n number?]) string?]{
  Converte um número em seu formato de texto (@tt{string}).

  @racketblock[
    (numero->texto 456) ; resulta em "456"
  ]
}

@defproc[(texto-maiusculo [txt string?]) string?]{
  Converte todos os caracteres do texto para letras maiúsculas.

  @racketblock[
    (texto-maiusculo "adaptativa") ; resulta em "ADAPTATIVA"
  ]
}

@defproc[(texto-minusculo [txt string?]) string?]{
  Converte todos os caracteres do texto para letras minúsculas.

  @racketblock[
    (texto-minusculo "BOM DIA!") ; resulta em "bom dia!"
  ]
}

@section{Computação Visual e Gráficos}

As funções gráficas do módulo visual permitem criar formas geométricas coloridas, combiná-las
espacialmente e posicioná-las em cenários bidimensionais.

As cores aceitam nomes expressivos em português (@"vermelho", @"azul", @"verde", @"amarelo", @"preto", @"branco", @"laranja", @"roxo", @"cinza", @"cinza-claro", @"marrom", @"rosa", @"azul-ceu", @"verde-escuro", @"dourado", @"prata").
Os modos de preenchimento aceitam @"solido" (preenchido) ou @"contorno" (linhas externas).

@defproc[(desenhar-circulo [raio real?] [modo (or/c string? symbol?) "solido"] [cor (or/c string? symbol?) "azul"]) any/c]{
  Desenha um círculo geométrico com o raio especificado.

  @racketblock[
    (desenhar-circulo 30 "solido" "azul")
    (desenhar-circulo 40 "contorno" "vermelho")
  ]
}

@defproc[(desenhar-quadrado [lado real?] [modo (or/c string? symbol?) "solido"] [cor (or/c string? symbol?) "vermelho"]) any/c]{
  Desenha um quadrado com o comprimento do lado especificado.

  @racketblock[
    (desenhar-quadrado 50 "solido" "verde")
  ]
}

@defproc[(desenhar-retangulo [largura real?] [altura real?] [modo (or/c string? symbol?) "solido"] [cor (or/c string? symbol?) "verde"]) any/c]{
  Desenha um retângulo com a largura e altura indicadas.

  @racketblock[
    (desenhar-retangulo 80 40 "solido" "laranja")
  ]
}

@defproc[(desenhar-triangulo [lado real?] [modo (or/c string? symbol?) "solido"] [cor (or/c string? symbol?) "laranja"]) any/c]{
  Desenha um triângulo equilátero com o lado especificado.

  @racketblock[
    (desenhar-triangulo 60 "solido" "amarelo")
  ]
}

@defproc[(desenhar-estrela [raio real?] [modo (or/c string? symbol?) "solido"] [cor (or/c string? symbol?) "amarelo"]) any/c]{
  Desenha uma estrela geométrica de cinco pontas com o raio indicado.

  @racketblock[
    (desenhar-estrela 35 "solido" "dourado")
  ]
}

@defproc[(desenhar-texto [conteudo any/c] [tamanho real? 20] [cor (or/c string? symbol?) "preto"]) any/c]{
  Desenha um texto estilizado como uma imagem gráfica para compor com cenários e desenhos.

  @racketblock[
    (desenhar-texto "Casa do Idoso" 24 "azul")
  ]
}

@defproc[(desenhar-cenario [largura real?] [altura real?] [cor (or/c string? symbol?) "branco"]) any/c]{
  Cria uma tela em branco com as dimensões de largura e altura especificadas para receber desenhos.

  @racketblock[
    (defina cenario como (desenhar-cenario 400 300 "azul-ceu"))
  ]
}

@defproc[(colocar-figura [figura any/c] [x real?] [y real?] [cenario any/c]) any/c]{
  Posiciona uma @racket[figura] nas coordenadas cartesianas (@racket[x], @racket[y]) sobre o @racket[cenario].
  A coordenada (0, 0) fica no canto superior esquerdo do cenário.

  @racketblock[
    (defina sol como (desenhar-circulo 25 "solido" "amarelo"))
    (defina tela como (desenhar-cenario 400 250 "azul-ceu"))
    (colocar-figura sol 320 60 tela)
  ]
}

@defproc[(largura-figura [fig any/c]) real?]{
  Retorna a largura em pixels de uma figura gráfica.

  @racketblock[
    (largura-figura (desenhar-retangulo 80 40)) ; resulta em 80
  ]
}

@defproc[(altura-figura [fig any/c]) real?]{
  Retorna a altura em pixels de uma figura gráfica.

  @racketblock[
    (altura-figura (desenhar-retangulo 80 40)) ; resulta em 40
  ]
}

@defproc[(figura? [val any/c]) boolean?]{
  Verifica se o valor fornecido é uma imagem gráfica válida do ecossistema educacional.

  @racketblock[
    (figura? (desenhar-circulo 20)) ; resulta em #true
    (figura? "texto comum")         ; resulta em #false
  ]
}

@defproc[(sobrepor [fig1 any/c] [fig2 any/c] [rest any/c] ...) any/c]{
  Sobrepõe figuras alinhando-as pelos seus centros (a primeira figura fica na frente da segunda).

  @racketblock[
    (sobrepor (desenhar-circulo 15 "solido" "vermelho")
              (desenhar-circulo 30 "solido" "amarelo"))
  ]
}

@defproc[(lado-a-lado [fig1 any/c] [fig2 any/c] [rest any/c] ...) any/c]{
  Alinha figuras horizontalmente, uma ao lado da outra, da esquerda para a direita.

  @racketblock[
    (lado-a-lado (desenhar-quadrado 30 "solido" "azul")
                 (desenhar-quadrado 30 "solido" "verde"))
  ]
}

@defproc[(acima-de [fig1 any/c] [fig2 any/c] [rest any/c] ...) any/c]{
  Alinha figuras verticalmente, uma em cima da outra, de cima para baixo.

  @racketblock[
    (acima-de (desenhar-triangulo 40 "solido" "vermelho")
              (desenhar-quadrado 40 "solido" "azul"))
  ]
}

@defproc[(rotacionar [angulo real?] [figura any/c]) any/c]{
  Gira uma figura gráfica no sentido anti-horário pelo ângulo em graus especificado.

  @racketblock[
    (rotacionar 45 (desenhar-quadrado 40 "solido" "roxo"))
  ]
}

@defproc[(espelhar-horizontal [figura any/c]) any/c]{
  Espelha a figura horizontalmente (inverte esquerda com direita).

  @racketblock[
    (espelhar-horizontal (desenhar-triangulo 40 "solido" "laranja"))
  ]
}

@defproc[(espelhar-vertical [figura any/c]) any/c]{
  Espelha a figura verticalmente (inverte topo com base).

  @racketblock[
    (espelhar-vertical (desenhar-triangulo 40 "solido" "verde"))
  ]
}

@defproc[(criar-animacao [funcao-quadro (-> natural-number/c any/c)]) any/c]{
  Abre uma janela gráfica de animação contínua no DrRacket. A função @racket[funcao-quadro] é chamada a cada tique do relógio (cerca de 28 vezes por segundo), recebendo o tempo decorrido @racket[t] (0, 1, 2, 3...) e retornando a cena correspondente àquele instante.

  @racketblock[
    (defina cenario como (desenhar-cenario 400 200 "azul-ceu"))
    (defina bola como (desenhar-circulo 15 "solido" "vermelho"))

    (definir (desenhar-quadro t)
      (colocar-figura bola (resto-divisao (* t 4) 400) 100 cenario))

    (criar-animacao desenhar-quadro)
  ]
}

@section{Geometria da Tartaruga (Turtle Graphics)}

O módulo @bold{lib/turtle.rkt} oferece a metáfora clássica da Tartaruga de Seymour Papert (popularizada no Logo e no Python), onde o aprendiz controla um agente que caminha pela tela desenhando formas no plano cartesiano.

A janela abre automaticamente ao executar o primeiro comando de desenho ou movimentação.
O centro da tela é o ponto cartesiano (0, 0), com o eixo X crescendo para a direita e o eixo Y crescendo para cima.

@defproc[(iniciar-tartaruga [largura integer? 600] [altura integer? 600]) void?]{
  Abre a janela gráfica da tartaruga com as dimensões especificadas (padrão 600x600).
  Sinônimos: @tt{tartaruga}, @tt{turtle}, @tt{abrir-tartaruga}.

  @racketblock[
    (iniciar-tartaruga 500 500)
  ]
}

@defproc[(fechar-tartaruga) void?]{
  Fecha a janela gráfica da tartaruga e encerra a sessão ativa de desenho.

  @racketblock[
    (fechar-tartaruga)
  ]
}

@defproc[(avancar [distancia real? 100]) void?]{
  Move a tartaruga para frente pela distância indicada em pixels. Se a caneta estiver abaixada, traça uma linha colorida.
  Sinônimos: @tt{frente}, @tt{forward}, @tt{fd}.

  @racketblock[
    (avancar 100)
  ]
}

@defproc[(recuar [distancia real? 100]) void?]{
  Move a tartaruga para trás pela distância indicada em pixels.
  Sinônimos: @tt{tras}, @tt{backward}, @tt{bk}.

  @racketblock[
    (recuar 50)
  ]
}

@defproc[(girar-direita [graus real? 90]) void?]{
  Gira a tartaruga no sentido horário (para a direita) pelo ângulo em graus indicado.
  Sinônimos: @tt{direita}, @tt{right}, @tt{rt}.

  @racketblock[
    (girar-direita 90)
  ]
}

@defproc[(girar-esquerda [graus real? 90]) void?]{
  Gira a tartaruga no sentido anti-horário (para a esquerda) pelo ângulo em graus indicado.
  Sinônimos: @tt{esquerda}, @tt{left}, @tt{lt}.

  @racketblock[
    (girar-esquerda 45)
  ]
}

@defproc[(ir-para [x real?] [y real?]) void?]{
  Move a tartaruga diretamente para as coordenadas cartesianas (@racket[x], @racket[y]), onde (0, 0) é o centro da tela.
  Sinônimos: @tt{posicao}, @tt{goto}, @tt{setpos}.

  @racketblock[
    (levantar-caneta)
    (ir-para -100 150)
    (abaixar-caneta)
  ]
}

@defproc[(definir-angulo [graus real?]) void?]{
  Define o ângulo absoluto de direção da tartaruga (0° = Leste/Direita, 90° = Norte/Cima, 180° = Oeste/Esquerda, 270° = Sul/Baixo).
  Sinônimo: @tt{setheading}.

  @racketblock[
    (definir-angulo 90) ; aponta para cima
  ]
}

@defproc[(levantar-caneta) void?]{
  Levanta a caneta do papel. A tartaruga pode se mover livremente sem desenhar traços.
  Sinônimos: @tt{levantar}, @tt{penup}, @tt{pu}.

  @racketblock[
    (levantar-caneta)
    (avancar 50)
  ]
}

@defproc[(abaixar-caneta) void?]{
  Abaixa a caneta no papel para voltar a desenhar linhas enquanto se move.
  Sinônimos: @tt{abaixar}, @tt{pendown}, @tt{pd}.

  @racketblock[
    (abaixar-caneta)
    (avancar 100)
  ]
}

@defproc[(caneta-abaixada?) boolean?]{
  Retorna @racket[#true] se a caneta estiver abaixada no papel desenhando, ou @racket[#false] se estiver levantada.
  Sinônimo: @tt{isdown?}.

  @racketblock[
    (se (caneta-abaixada?)
        (mostrar "Caneta pronta para desenhar!")
        (mostrar "Caneta levantada."))
  ]
}

@defproc[(mudar-cor [cor (or/c string? symbol?)]) void?]{
  Altera a cor do traço da caneta. Aceita cores em português (@"azul", @"vermelho", @"verde", @"amarelo", @"laranja", @"roxo", @"dourado", @"preto", etc.).
  Sinônimos: @tt{cor-caneta}, @tt{pencolor}.

  @racketblock[
    (mudar-cor "azul")
    (mudar-cor "dourado")
  ]
}

@defproc[(mudar-espessura [espessura real?]) void?]{
  Altera a espessura em pixels da linha desenhada pela caneta.
  Sinônimos: @tt{espessura-caneta}, @tt{pensize}.

  @racketblock[
    (mudar-espessura 4)
  ]
}

@defproc[(limpar-tela) void?]{
  Apaga todos os desenhos realizados na tela, deixando o fundo branco.
  Sinônimos: @tt{limpar}, @tt{clear}.

  @racketblock[
    (limpar-tela)
  ]
}

@defproc[(voltar-ao-centro) void?]{
  Retorna a tartaruga imediatamente para o ponto central (0, 0) apontando para cima (90°).
  Sinônimos: @tt{centro}, @tt{home}.

  @racketblock[
    (voltar-ao-centro)
  ]
}

@defproc[(esconder-tartaruga) void?]{
  Oculta o ícone visual da tartaruga na tela, deixando apenas a obra artística final visível.
  Sinônimos: @tt{hideturtle}, @tt{ht}.

  @racketblock[
    (esconder-tartaruga)
  ]
}

@defproc[(mostrar-tartaruga) void?]{
  Torna o ícone visual da tartaruga visível novamente na tela.
  Sinônimos: @tt{showturtle}, @tt{st}.

  @racketblock[
    (mostrar-tartaruga)
  ]
}

@defproc[(tartaruga-visivel?) boolean?]{
  Retorna se o ícone da tartaruga está visível na tela no momento.

  @racketblock[
    (tartaruga-visivel?) ; resulta em #true ou #false
  ]
}

@defproc[(velocidade-tartaruga [nivel integer? 5]) void?]{
  Controla a velocidade da animação ao desenhar. Use @racket[0] para desenho instantâneo (padrão), ou valores de @racket[1] (bem devagar) até @racket[10] (rápido e animado) para acompanhar a tartaruga riscando o papel passo a passo.
  Sinônimos: @tt{velocidade}, @tt{speed}.

  @racketblock[
    (velocidade-tartaruga 5) ; animação em velocidade média
    (avancar 150)
  ]
}

@defproc[(obter-x) real?]{
  Retorna a coordenada cartesiana horizontal X atual da tartaruga.
  Sinônimos: @tt{posicao-x}, @tt{xcor}.

  @racketblock[
    (mostrar "Posição X atual:" (obter-x))
  ]
}

@defproc[(obter-y) real?]{
  Retorna a coordenada cartesiana vertical Y atual da tartaruga.
  Sinônimos: @tt{posicao-y}, @tt{ycor}.

  @racketblock[
    (mostrar "Posição Y atual:" (obter-y))
  ]
}

@defproc[(obter-angulo) real?]{
  Retorna o ângulo de direção atual da tartaruga em graus (0 a 360).
  Sinônimo: @tt{heading}.

  @racketblock[
    (mostrar "Ângulo atual:" (obter-angulo))
  ]
}

@defproc[(salvar-desenho [caminho path-string?]) void?]{
  Salva a imagem artística desenhada na tela em um arquivo de imagem no formato PNG.

  @racketblock[
    (salvar-desenho "meu-desenho-tartaruga.png")
  ]
}

@subsection{Exemplo de Desenho Completo com a Tartaruga}

O exemplo a seguir desenha uma estrela dourada de 5 pontas passo a passo, usando o controle de velocidade da tartaruga:

@racketblock[
  (iniciar-tartaruga)
  (velocidade-tartaruga 6) ; animação em velocidade média (1 a 10)
  (mudar-cor "dourado")
  (mudar-espessura 3)

  ;; Desenha estrela de 5 pontas
  (repetir 5 vezes
    (avancar 150)
    (girar-direita 144))

  (esconder-tartaruga)
]

@section{Testes e Verificações Automatizadas}

@defform[(verificar-resultado expr resultado-esperado)]{
  Testa se a avaliação de @racket[expr] produz exatamente @racket[resultado-esperado].
  O DrRacket destaca em verde os testes bem-sucedidos e exibe uma janela informativa caso ocorra alguma divergência.

  @racketblock[
    (verificar-resultado (+ 2 3) 5)
    (verificar-resultado (e-par? 8) verdadeiro)
    (verificar-resultado (juntar-texto "A" "B") "AB")
  ]
}

@defform[(verificar-erro expr mensagem-esperada)]{
  Testa se a avaliação de @racket[expr] resulta em um erro com a mensagem especificada.

  @racketblock[
    (verificar-erro (/ 10 0) "/: division by zero")
  ]
}

@defform[(verificar-aproximado expr resultado-esperado tolerancia)]{
  Testa se a expressão resulta em um valor numérico próximo ao esperado, dentro da tolerância permitida.

  @racketblock[
    (verificar-aproximado (raiz-quadrada 2) 1.414 0.01)
  ]
}

@section{Transição Bilíngue (Níveis 2 e 3 - How to Design Programs)}

A partir do Nível 2 (conquistado automaticamente por pontuação ou configurado pelo mediador), o aprendiz inicia a transição bilíngue e desbloqueia a sintaxe canônica internacional em Inglês do @bold{How to Design Programs (HtDP)}, atingindo autonomia plena no Nível 3.

No Nível 1 (Iniciante), o uso desses termos em inglês é bloqueado pedagogicamente, orientando o aluno a praticar os comandos em Português. A partir do Nível 2, todos os termos abaixo passam a ser aceitos:

@itemlist[
  @item{@racket[define] - Equivalente internacional a @racket[definir] e @racket[defina].}
  @item{@racket[if] - Equivalente internacional a @racket[se].}
  @item{@racket[cond] - Equivalente internacional a @racket[escolha].}
  @item{@racket[else] - Equivalente internacional a @racket[senao].}
  @item{@racket[check-expect] - Equivalente internacional a @racket[verificar-resultado].}
  @item{@racket[define-struct] - Equivalente internacional a @racket[definir-registro].}
  @item{@racket[and] - Equivalente internacional a @racket[e].}
  @item{@racket[or] - Equivalente internacional a @racket[ou].}
  @item{@racket[not] - Equivalente internacional a @racket[nao].}
  @item{@racket[sqr] - Equivalente internacional a @racket[quadrado].}
  @item{@racket[expt] - Equivalente internacional a @racket[potencia].}
  @item{@racket[quotient] - Equivalente internacional a @racket[quociente].}
]

@racketblock[
  ;; Exemplo em Nível 3 usando a sintaxe canônica HtDP:
  (define (calcular-area lado)
    (sqr lado))

  (define (em-intervalo? x)
    (and (>= x 10) (<= x 20)))

  (check-expect (calcular-area 5) 25)
  (check-expect (em-intervalo? 15) #true)
]
