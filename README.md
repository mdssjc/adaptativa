# Linguagem Educacional Adaptativa (`#lang adaptativa`)

[![Racket](https://img.shields.io/badge/Racket-9.3+-blue.svg)](https://racket-lang.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![DrRacket](https://img.shields.io/badge/DrRacket-Plugin%20Integrated-purple.svg)](https://racket-lang.org/)
[![ODS 04](https://img.shields.io/badge/ODS%2004-Educa%C3%A7%C3%A3o%20de%20Qualidade-orange.svg)](https://brasil.un.org/pt-br/sdgs/4)

A **Linguagem Educacional Adaptativa** (`#lang adaptativa`) é um ambiente de aprendizado e linguagem de programação funcional em língua portuguesa integrado nativamente ao **DrRacket**. O projeto foi concebido para o ensino de pensamento computacional e inclusão digital, com foco especial em pessoas idosas e iniciantes, alinhando-se à metodologia pedagógica do livro *How to Design Programs* (HtDP).

---

## 🎯 Contexto e Objetivos

- **Objetivo Principal:** Reduzir as barreiras de entrada no aprendizado de programação por meio de vocabulário em português, feedback pedagógico acolhedor e interface gráfica assistida.
- **Público-Alvo:** Idosos e pessoas em processo inicial de inclusão digital e alfabetização lógica.
- **Contexto de Extensão:** Desenvolvido no âmbito do projeto de Atividades Extensionistas (Bacharelado em Ciência da Computação - UNINTER), em consonância com o **ODS 04 da ONU (Educação de Qualidade)**, com aplicação prática na Casa do Idoso Sul (São José dos Campos / SP).

---

## 🌟 Principais Recursos

- **Feedback Didático Escalonado:** Máquina de mensagens adaptativas em 3 níveis (pergunta reflexiva socrática, lembrete prático com exemplo e guia estruturado no formato HtDP).
- **Progressão Sintática em 3 Níveis:** Permite que o aprendiz comece com vocabulário estritamente em português (Nível 1), avance para comandos bilíngues (Nível 2) e alcance autonomia nas convenções padrão do Racket BSL (Nível 3).
- **Plugin Nativo para o DrRacket:** Barra de ferramentas integrada ao topo do editor com:
  - **Identificação do Aluno:** Exibição do aprendiz ativo, pontuação e nível atual.
  - **📚 Aulas:** Leitor interativo dos roteiros de oficina com formatação e botão de cópia de exemplos.
  - **💡 Dica:** Consultas rápidas a orientações adequadas ao nível do aluno.
  - **📊 Relatório:** Painel analítico de desempenho pedagógico e conceitos dominados.
  - **⚙️ Configurações (PIN Docente):** Painel protegido para cadastro de alunos e ajuste de regras de progressão.
- **Sistema de Pontuação (Auto-Scoring):** Avaliação estática e dinâmica baseada em conceitos aplicados e testes automatizados validados.
- **Persistência Local e Segura:** Progresso dos estudantes e eventos da oficina armazenados localmente no perfil do usuário, preservando o histórico entre reinicializações.

---

## 🚀 Como Instalar

### Pré-requisitos
- **Racket 9.3 ou superior** (com a interface **DrRacket**): [Download oficial do Racket](https://download.racket-lang.org/)
- **Git** instalado (ou faça o download dos arquivos do projeto)

### Passo a Passo

1. **Obtenha o repositório:**
   ```bash
   git clone https://github.com/mdssjc/adaptativa.git
   cd adaptativa
   ```

2. **Vincule o pacote ao Racket:**
   No terminal, dentro da pasta do projeto, execute o script de instalação automática:
   ```bash
   racket install.rkt
   ```
   *(Como alternativa, você pode instalar diretamente com o utilitário do Racket:)*
   ```bash
   raco pkg install --link --name adaptativa .
   raco setup --pkgs adaptativa
   ```

3. **Inicie o DrRacket:**
   Abra o **DrRacket**. O plugin e a linguagem já estarão ativos e disponíveis no ambiente.

---

## 💻 Como Utilizar

### 1. Preparação no DrRacket
1. Inicie o DrRacket.
2. Certifique-se de que a linguagem do ambiente esteja configurada como **"Determine language from source"** (opção padrão localizada no rodapé ou em *Language* > *Choose Language...*).
3. Na barra de ferramentas superior exibida pelo plugin:
   - Clique em **⚙️ Configurações** (no primeiro acesso, será solicitado o cadastro de um PIN docente de sua escolha) para cadastrar os alunos da turma.
   - Selecione o aluno ativo na lista para que todo o progresso e pontuação sejam registrados no perfil correto.
   - Utilize o botão **📚 Aulas** para abrir os roteiros passo a passo das oficinas.

### 2. Criando e Executando um Programa
No editor de texto do DrRacket, inicie o arquivo declarando a linguagem na primeira linha:

```racket
#lang adaptativa

;; Exibição de mensagem
(mostrar "Olá! Bem-vindos à informática criativa!")

;; Criação de valores e variáveis
(defina nome como "Dona Maria")
(defina passos-hoje como 3500)

(mostrar (juntar-texto "Aprendiz: " nome))
(mostrar (juntar-texto "Passos realizados: " passos-hoje))

;; Definição de funções simples
(definir (dobro valor)
  (* valor 2))

(mostrar (juntar-texto "O dobro de 50 é: " (dobro 50)))
```

Para rodar:
- Clique no botão **Executar (Run)** no canto superior direito (ou pressione `Ctrl + R` / `Cmd + R`).
- O resultado será exibido na área inferior de interações e a pontuação do aluno ativo será recalculada automaticamente na barra superior.

---

## 🧪 Testes Automatizados

Para verificar a integridade da suíte de testes do projeto:

```bash
raco test tests
```

---

## 📄 Licença

Distribuído sob a licença **MIT**. Consulte o arquivo de licença para mais informações.
