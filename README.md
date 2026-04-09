# ai

A collection of reusable AI agents, prompt workflows, skills, and language standards.
Everything here is designed to be dropped into a project and used immediately with GitHub Copilot.

---

## Contents

### [`agents/`](agents/)

Copilot chat agents — invokable by name in the agent panel.

| Agent | Description |
|---|---|
| [`agent-designer`](agents/agent-designer/) | Creates, reviews, and improves custom Copilot agents (`.agent.md` files) — single agents and coordinated groups |
| [`feature-designer`](agents/feature-designer/) | Researches, designs, and plans features and tasks for development |
| [`system-designer`](agents/system-designer/) | System design assistant — generates and refactors `design.md` and UML diagrams |
| [`tdd-workflow`](agents/tdd-workflow/README.md) | Orchestrates a full TDD lifecycle across focused subagents — research, test writing, implementation, quality audit |
| [`ts-tutor`](agents/ts-tutor/) | TypeScript tutor for .NET and Python developers |

---

### [`prompts/`](prompts/)

File-based prompt workflows — attach as `#file` references in Copilot chat, no agent
setup required.

| Folder | Description |
|---|---|
| [`prompts/tdd/`](prompts/tdd/README.md) | TDD workflow: tool discovery, standards routing, RED/GREEN/REFACTOR cycle with approval gates |

---

### [`skills/`](skills/)

Reusable skills that extend agent capabilities.

| Skill | Description |
|---|---|
| [`commit`](skills/commit/) | Analyzes working directory changes, composes conventional commit messages, and executes VCS operations after user approval |
| [`repo-onboarding`](skills/repo-onboarding/README.md) | Generates four onboarding docs for a repo: tooling commands, architecture, summary, and quickstart |
| [`standards-compliance`](skills/standards-compliance/README.md) | Enforces project coding standards on all produced code changes — resolves conflicts between task specs and standards |

---

### [`tools/`](tools/)

Multi-agent tool suites.

| Tool | Description |
|---|---|
| [`sda`](tools/sda/README.md) | Software Development Assistant — five coordinated agents for specification-driven development (init → system → feature → task → dev) |

---

### [`resources/`](resources/README.md)

Coding standards, tool-discovery specs, and shared development workflow — used by both the `tdd-workflow`
agents and the `prompts/tdd/` workflow.

| Resource | Contents |
|---|---|
| `resources/common-standards.md` | Language-agnostic coding rules (SOLID, AAA, behavioral testing, etc.) |
| `resources/development-workflow.md` | Shared, language-independent TDD process and quality gates |
| `resources/java/` | `tool-discovery.md`, `coding-standards.md`, `testing-standards.md`, `code-style.md` |
| `resources/typescript/` | `tool-discovery.md`, `coding-standards.md`, `testing-standards.md`, `code-style.md` |
| `resources/python/` | `tool-discovery.md`, `coding-standards.md`, `testing-standards.md`, `code-style.md` |

---

### [`scripts/`](scripts/)

Installation and update scripts.

| Script | Description |
|---|---|
| `install-dev-suite.bat` | Installs the dev suite into a project |
| `update-skill.ps1` | Updates a skill from this repo into a target project |
| `update-standards-compliance.ps1` | Updates the standards-compliance skill specifically |
| `update-tool.ps1` | Updates a tool from this repo into a target project |

---

## Agent vs prompt workflow

Both `agents/tdd-workflow` and `prompts/tdd` implement the same TDD process. Choose
based on how you work:

| | `agents/tdd-workflow` | `prompts/tdd` |
|---|---|---|
| How to invoke | Agent panel in Copilot Chat | `#file` reference in chat |
| Setup | Copy `resources/{language}` into `.tdd-workflow/` in your project | Copy `resources/{language}` into `standards/` next to the prompt files |
| Orchestration | Dedicated orchestrator agent with strict phase enforcement | Single file routes the assistant |
| Best for | Complex features, teams wanting enforced workflow | Quick use, minimal setup |
