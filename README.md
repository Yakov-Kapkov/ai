# ai

A collection of reusable AI agents, prompt workflows, skills, and language standards.
Everything here is designed to be dropped into a project and used immediately with GitHub Copilot.

---

## ⚡ Install

Use `sda-cli` to install the SDA agents and prompts directly into your project.

### 1. One-time usage (no install)

```bash
uvx --from git+https://github.com/Yakov-Kapkov/ai.git ai-tools list
uvx --from git+https://github.com/Yakov-Kapkov/ai.git ai-tools install sda
uvx --from git+https://github.com/Yakov-Kapkov/ai.git ai-tools install sda --language typescript
```

### Upgrade the CLI

```bash
uv tool install ai-tools-cli --force --from git+https://github.com/Yakov-Kapkov/ai.git
```

### 2. Install the CLI (persistent, recommended)

```bash
uv tool install ai-tools-cli --from git+https://github.com/Yakov-Kapkov/ai.git
```

Then from inside your project:

```bash
ai-tools list                                        # show available tools and status

ai-tools install sda                                 # agents + prompts + .dev-assistant
ai-tools install sda --language typescript           # + TypeScript standards
ai-tools install sda --language typescript,python    # + both

ai-tools update sda                                  # overwrite with latest
ai-tools uninstall sda
```

---

## Contents

### [`agents/`](agents/)

Copilot chat agents — invokable by name in the agent panel.

| Agent | Description |
|---|---|
| [`tdd-workflow`](agents/tdd-workflow/README.md) | Orchestrates a full TDD lifecycle across six focused subagents — research, test writing, implementation, quality audit |
| [`ba-assistant`](agents/ba-assistant/README.md) | Brainstorms, researches, and plans new features — no implementation |

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
| [`repo-onboarding`](skills/repo-onboarding/README.md) | Generates four onboarding docs for a repo: tooling commands, architecture, summary, and quickstart |

---

### [`resources/`](resources/README.md)

Language-specific standards and tool-discovery specs shared by both the `tdd-workflow`
agents and the `prompts/tdd/` workflow.

| Language | Contents |
|---|---|
| `resources/typescript/` | `tool-discovery.md`, `coding-standards.md`, `testing-standards.md`, `code-style.md` |
| `resources/python/` | `tool-discovery.md`, `coding-standards.md`, `testing-standards.md`, `code-style.md` |

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
