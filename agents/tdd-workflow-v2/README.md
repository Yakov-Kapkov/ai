# tdd-workflow-v2 agent

A streamlined suite of three coordinated AI agents that enforce a strict Test-Driven Development lifecycle. Unlike v1's orchestrator model, v2 is **handoff-driven** — each agent completes its phase and passes control to the next via structured handoffs. Users invoke agents directly at any stage.

---

## Agents

| Agent | Role | Model | User-invokable | Tools |
|---|---|---|---|---|
| `init` | Detects project toolchain, writes `project-tools.md` and `project-config.json` | Claude Haiku 4.5 | ✅ (once per project) | read, search, edit |
| `feature-designer` | Brainstorms, designs, and produces a structured feature specification | Default | ✅ | read, edit, search, web |
| `implementer` | Writes failing tests, makes them pass, refactors, and runs quality checks | Claude Sonnet 4.6 | ✅ | read, edit, search, execute |

All three agents are user-invokable. `init` is run once per project; `feature-designer` and `implementer` are used per task.

---

## Setup

### 1. Create the `.tdd-workflow` folder

Create a `.tdd-workflow/` folder at your project root and copy the resource files from this repo's [`../../resources/`](../../resources/) folder into it. Copy bootstrap.md and project-config.example.json files from `resources/` folder to `.tdd-workflow/` folder. 

You should see something like that:

```
<your-project>/
└── .tdd-workflow/
    └── resources/
        ├── bootstrap.md
        ├── project-config.example.json
        └── typescript/
            ├── tool-discovery.md
            └── standards/
                ├── coding-standards.md
                ├── testing-standards.md
                └── code-style.md
        └── <another language>
        ...
```

| File | Purpose |
|---|---|
| `bootstrap.md` | Shared initialization steps read by `implementer` at the start of every session |
| `project-config.example.json` | Example `project-config.json` — copy to `.tdd-workflow/project-config.json` and adjust |
| `tool-discovery.md` | Spec the `init` agent follows to detect your toolchain |
| `standards/coding-standards.md` | Mandatory coding rules enforced by `implementer` |
| `standards/testing-standards.md` | Mandatory testing rules enforced by `implementer` |
| `standards/code-style.md` | Style rules (naming, comments, formatting) enforced by `implementer` |

### 2. Run the `init` agent

Invoke the `init` agent once per project. It will scan your toolchain, present its findings for approval, and write `.tdd-workflow/project-tools.md` and `.tdd-workflow/project-config.json`.

---

## Usage

### 1. Initialize the project (once) - **init** agent

Invoke the `init` agent in a new chat:

```
Set up the TDD workflow for this project.
```

`init` will scan your project, present its findings, and — after your approval — write `project-tools.md` and `project-config.json`.

### 2. Design a feature - **feature-designer** agent

Invoke the `feature-designer` agent and describe your task:

```
Add an endpoint that returns a paginated list of orders filtered by status.
```

```
Refactor UserRepository to extract a separate QueryBuilder class.
```

The agent will collaborate with you on the design and save a `feature.md` to a numbered task folder.

### 3. Implement - **implementer** agent

Invoke the `implementer` agent and reference your task:

```
Implement the current feature.
```

```
Implement task 03-order-list-endpoint.
```

For quick, one-off changes without a feature spec, describe the task directly (ad-hoc mode):

```
Fix the bug where createOrder throws when quantity is 0.
```

---

## Workflow phases

```
PHASE 0 — INIT  (once per project)
  Detect OS, shell, and language from project markers.
  Read tool-discovery spec → scan for test runner, linter, type checker, etc.
  Present findings to user for approval.
  Write .tdd-workflow/project-tools.md and .tdd-workflow/project-config.json.
  Handoff → feature-designer.

PHASE 1 — DESIGN
  feature-designer brainstorms the feature with the user.
  Researches the codebase (read-only).
  Produces .tdd-workflow/tasks/<NN>-<task-name>/feature.md with acceptance
  criteria, test scenarios, and implementation plan.
  Handoff → implementer.

PHASE 2 — RED
  implementer reads bootstrap + all standards files.
  Reads feature.md and state.md.
  Writes failing tests for every approved scenario.
  Confirms RED state (tests fail as expected).

PHASE 3 — GREEN
  implementer writes production code to make all tests pass.
  Re-runs tests until fully green.

PHASE 4 — REFACTOR + QUALITY CHECKS
  implementer refactors for quality while keeping all tests green.
  Runs mandatory quality gates: tests, coverage, type-check, lint.
  Presents results and exact commands to the user.
```

### Mode routing (implementer)

| Invocation | Mode | Behaviour |
|---|---|---|
| Task name / "implement the current feature" / attached `feature.md` | `task` | Full TDD workflow — RED → GREEN → refactor → quality checks |
| Coding request without a task folder | `ad-hoc` | Implement directly — standards and quality checks still enforced |

---

## Configuration

All resources are read from a `.tdd-workflow/` folder in the project root (may be git-ignored). Agents always use exact literal paths — they never search for these files.

| Resource | Path |
|---|---|
| Project tools (commands) | `.tdd-workflow/project-tools.md` |
| Project config (coverage, etc.) | `.tdd-workflow/project-config.json` |
| Tool-discovery spec | `.tdd-workflow/resources/{language}/tool-discovery.md` |
| Coding standards | `.tdd-workflow/resources/{language}/standards/coding-standards.md` |
| Testing standards | `.tdd-workflow/resources/{language}/standards/testing-standards.md` |
| Code style | `.tdd-workflow/resources/{language}/standards/code-style.md` |
| Task feature spec | `.tdd-workflow/tasks/<NN>-<task-name>/feature.md` |
| Task progress state | `.tdd-workflow/tasks/<NN>-<task-name>/state.md` |

`{language}` is inferred from project markers (`package.json` → `typescript`, `pyproject.toml` / `requirements.txt` → `python`).

### project-tools.md

Written by `init` on first run (after user approval). Contains the commands `feature-designer` and `implementer` use to run tests, check types, lint, measure coverage, and run specific files. Must exist before `implementer` proceeds — a missing file triggers a hard stop.

### project-config.json

Written by `init`. Stores project-level settings, primarily coverage configuration. If missing, `implementer` defaults to `{ "tests": { "coverage": { "enabled": true, "threshold": 95 } } }`.

Example:
```json
{
  "tests": {
    "coverage": {
      "enabled": true,
      "threshold": 95
    }
  }
}
```

### Standards files

Read in full by `implementer` at the start of every session — before any source file is read or written. Every rule is treated as mandatory; there are no optional guidelines.

---

## Key design constraints

- **`init` runs once per project, not per task.** Re-run it only if the toolchain changes.
- **`feature-designer` is read-only on the codebase.** It researches but never edits source files. All edits are scoped to `.tdd-workflow/tasks/`.
- **`implementer` hard-stops if `project-tools.md` is missing.** There is no fallback — run `init` first.
- **Standards are mandatory, always.** `implementer` reads all standards files before every session — even for trivial fixes or ad-hoc requests.
- **Quality checks are non-negotiable.** After any code change, `implementer` must run and pass all quality gates (tests, coverage, types, lint) before finishing.
- **Tests must be failing before GREEN begins.** `implementer` confirms the RED state before writing production code.
- **Complexity is proportional.** `feature-designer` matches design depth to task scope — no patterns, abstractions, or architectural discussions for small, single-file changes.
