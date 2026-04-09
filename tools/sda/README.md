# SDA — Software Development Assistant

A suite of coordinated AI agents that implement a Specification-Driven Development workflow. The system is **handoff-driven** — each agent completes its phase and passes control to the next. Users can invoke any agent directly at any stage.

```
sda-init  →  sda-system  →  sda-feature  →  sda-task  →  sda-dev / sda-dev-orc
(once)       (design)       (features)      (tasks)      (implement)
```

---

## Agents

### Pipeline agents

| Agent | Role | Model | Tools |
|---|---|---|---|
| `sda-init` | Detects project toolchain, writes `project-tools.md` and `project-config.json` | Claude Haiku 4.5 | read, search, edit |
| `sda-system` | System architecture design — components, contracts, diagrams | Claude Sonnet 4.6 | read, edit, search, agent |
| `sda-feature` | Feature-level design through collaborative brainstorming | Claude Sonnet 4.6 | read, edit, search |
| `sda-task` | Designs atomic task specs (`task.md`) with test scenarios and implementation plans | Claude Sonnet 4.6 | read, edit, search |
| `sda-dev` | TDD implementation — monolithic (RED → GREEN → refactor) and quality checks | Claude Sonnet 4.6 | read, edit, search, execute, todo |
| `sda-dev-orc` | TDD implementation — orchestrator variant that delegates to subagents for reduced context | Claude Sonnet 4.6 | read, edit, execute, agent |

### Subagents (invoked by `sda-dev-orc`)

| Agent | Role | Model | Tools |
|---|---|---|---|
| `sda-test-writer` | Writes tests for TDD slices (RED) and tests-only slices | Claude Sonnet 4.6 | read, edit, search, execute |
| `sda-coder` | Implements production code (GREEN), integration slices, and refactoring | Claude Sonnet 4.6 | read, edit, search, execute |

`sda-dev` and `sda-dev-orc` are interchangeable — use `sda-dev` for simple tasks, `sda-dev-orc` for complex multi-slice tasks where context size causes reasoning loops.

All pipeline agents are user-invokable. `sda-init` is run once per project; the rest are used as needed.

---

## Setup

### 1. Create the `.dev-assistant` folder

1. Copy the [`.dev-assistant/`](.dev-assistant/) folder from this repo into your project root.
2. Copy the language folder(s) you need from [`../../resources/`](../../resources/) into `.dev-assistant/resources/`.

Your project should have:

```
<your-project>/
└── .dev-assistant/
    └── resources/
        ├── bootstrap.md
        ├── project-config.example.json
        └── <language>/          (e.g. typescript/, python/)
            └── tool-discovery.md
```

| File | Purpose |
|---|---|
| `bootstrap.md` | Shared initialization steps read by `sda-dev` at the start of every session |
| `project-config.example.json` | Example `project-config.json` — copy to `.dev-assistant/project-config.json` and adjust |
| `tool-discovery.md` | Spec the `sda-init` agent follows to detect your toolchain |

### 2. Install the Standards Compliance skill (recommended)

SDA works best with the [**Standards Compliance**](../../skills/standards-compliance/) skill installed. The skill enforces coding standards, testing standards, and code style rules on all code produced by `sda-dev` — keeping output consistent without manual review.

See the [Standards Compliance README](../../skills/standards-compliance/README.md) for installation instructions.

### 3. Run the `sda-init` agent

Invoke the `sda-init` agent (or the `/sda-init` prompt) once per project. It will scan your toolchain, present its findings for approval, and write `.dev-assistant/project-tools.md` and `.dev-assistant/project-config.json`.

---

## Usage

### 1. Initialize the project (once) — `sda-init`

Invoke the `sda-init` agent in a new chat:

```
Set up the TDD workflow for this project.
```

`sda-init` will scan your project, present its findings, and — after your approval — write `project-tools.md` and `project-config.json`.

### 2. Design system architecture (optional) — `sda-system`

For larger efforts, start with system-level design:

```
Design the architecture for the notification subsystem.
```

Produces a `design.md` with components, contracts, and diagrams. Hands off to `sda-feature` when ready.

### 3. Design a feature — `sda-feature`

```
Design a feature for paginated order listing filtered by status.
```

The agent collaborates on the design, challenges over-engineering, and saves a `feature.md`. Hands off to `sda-task` to split into tasks.

### 4. Design a task — `sda-task`

```
Design a task for the order list endpoint.
```

Produces a `task.md` with test scenarios, implementation plan, and `state.md` for tracking. Hands off to `sda-dev` for implementation.

### 5. Implement — `sda-dev`

```
Implement the current task.
```

```
Implement task 03-order-list-endpoint.
```

For quick, one-off changes without a task spec (ad-hoc mode):

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
  Write .dev-assistant/project-tools.md and .dev-assistant/project-config.json.
  Handoff → sda-feature-designer.

PHASE 1 — DESIGN
  sda-feature-designer brainstorms the feature with the user.
  Researches the codebase (read-only).
  Produces .dev-assistant/tasks/<NN>-<task-name>/feature.md with acceptance
  criteria, test scenarios, and implementation plan.
  Handoff → sda-dev.

PHASE 2 — RED
  sda-dev reads bootstrap.
  Reads feature.md and state.md.
  Writes failing tests for every approved scenario.
  Confirms RED state (tests fail as expected).

PHASE 3 — GREEN
  sda-dev writes production code to make all tests pass.
  Re-runs tests until fully green.

PHASE 4 — REFACTOR + QUALITY CHECKS
  sda-dev refactors for quality while keeping all tests green.
  Runs mandatory quality gates: tests, coverage, type-check, lint.
  Presents results and exact commands to the user.
```

### Mode routing (sda-dev)

| Invocation | Mode | Behaviour |
|---|---|---|
| Task name / "implement the current feature" / attached `feature.md` | `task` | Full TDD workflow — RED → GREEN → refactor → quality checks |
| Coding request without a task folder | `ad-hoc` | Implement directly — standards and quality checks still enforced |

---

## Configuration

All resources are read from a `.dev-assistant/` folder in the project root (may be git-ignored). Agents always use exact literal paths — they never search for these files.

| Resource | Path |
|---|---|
| Project tools (commands) | `.dev-assistant/project-tools.md` |
| Project config (coverage, etc.) | `.dev-assistant/project-config.json` |
| Bootstrap | `.dev-assistant/resources/bootstrap.md` |
| Tool-discovery spec | `.dev-assistant/resources/{language}/tool-discovery.md` |
| Task feature spec | `.dev-assistant/tasks/<NN>-<task-name>/feature.md` |
| Task progress state | `.dev-assistant/tasks/<NN>-<task-name>/state.md` |

`{language}` is inferred from project markers (`package.json` → `typescript`, `pyproject.toml` / `requirements.txt` → `python`).

### project-tools.md

Written by `sda-init` on first run (after user approval). Contains the commands `sda-feature-designer` and `sda-dev` use to run tests, check types, lint, measure coverage, and run specific files. Must exist before `sda-dev` proceeds — a missing file triggers a hard stop.

### project-config.json

Written by `sda-init`. Stores project-level settings, primarily coverage configuration. If missing, `sda-dev` defaults to `{ "tests": { "coverage": { "enabled": true, "threshold": 95 } } }`.

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

Read in full by `sda-dev` at the start of every session — before any source file is read or written. Every rule is treated as mandatory; there are no optional guidelines.

---

## Key design constraints

- **`sda-init` runs once per project, not per task.** Re-run it only if the toolchain changes.
- **`sda-feature-designer` is read-only on the codebase.** It researches but never edits source files. All edits are scoped to `.dev-assistant/tasks/`.
- **`sda-dev` hard-stops if `project-tools.md` is missing.** There is no fallback — run `sda-init` first.
- **Standards are mandatory, always.** `sda-dev` reads all standards files before every session — even for trivial fixes or ad-hoc requests.
- **Quality checks are non-negotiable.** After any code change, `sda-dev` must run and pass all quality gates (tests, coverage, types, lint) before finishing.
- **Tests must be failing before GREEN begins.** `sda-dev` confirms the RED state before writing production code.
- **Complexity is proportional.** `sda-feature-designer` matches design depth to task scope — no patterns, abstractions, or architectural discussions for small, single-file changes.
