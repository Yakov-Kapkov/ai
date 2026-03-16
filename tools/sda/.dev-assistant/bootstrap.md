# Bootstrap — shared initialization for TDD agents

Follow these steps at the start of every task before doing agent-specific work.

---

## 1. Detect language

Read project root markers with the `read` tool to determine the language:

| Marker file | Language |
|---|---|
| `package.json` | `typescript` |
| `pyproject.toml` or `requirements.txt` | `python` |
| Other manifest/config files | Infer from context |

If no marker is found or the language is ambiguous, ask: _"Could not detect
the project language. Please specify."_

---

## 2. Verify project tooling

Read `./.dev-assistant/project-tools.md` and `./.dev-assistant/project-config.json`.

If `project-tools.md` is missing → **HARD STOP. No exceptions. No workarounds.
Do not search for it elsewhere. Do not read project manifest files as a substitute.
Do not reason about what the user "probably wants". Do not continue.**
Print exactly: _"Project not initialized.
Invoke the **init** agent in a new chat to set up project tooling."_
Then end your response. Nothing else.

If `project-config.json` is missing → continue with defaults
(`tests.coverage.enabled: true`, `tests.coverage.threshold: 95`).

---

## 3. Resolve CONFIG_PATHS

All resources live inside `.dev-assistant/`. This folder may be hidden
(dot-folder) — **never use search tools to locate it**. Always use the `read`
tool with exact literal paths.

| File | Path |
|---|---|
| Coding standards | `./.dev-assistant/resources/{language}/standards/coding-standards.md` |
| Testing standards | `./.dev-assistant/resources/{language}/standards/testing-standards.md` |
| Code style | `./.dev-assistant/resources/{language}/standards/code-style.md` |

CONFIG_PATHS is the combined set of all four files:
1. `./.dev-assistant/project-tools.md`
2. `./.dev-assistant/resources/{language}/standards/coding-standards.md`
3. `./.dev-assistant/resources/{language}/standards/testing-standards.md`
4. `./.dev-assistant/resources/{language}/standards/code-style.md`

Substitute `{language}` with the detected language (e.g. `typescript`,
`python`, `java`, etc.). If the corresponding `resources/{language}/` folder
does not exist, the project has no language-specific standards — warn the user
and continue with `project-tools.md` only. If any individual standards file is
missing, warn and continue with existing files.

---

## 4. Locate the task

The user provides a **task name** (e.g. `01-snowflake-config-provider`).
Task folders live at `./.dev-assistant/tasks/<task-name>/` and are numbered
sequentially with a two-digit prefix (e.g. `01-`, `02-`, `03-`).

Each task folder contains:

| File | Created by | Purpose |
|---|---|---|
| `feature.md` | `@feature-designer` | Feature specification with test scenarios |
| `state.md` | `@feature-designer` | Task progress — updated by each agent |

If the task folder or `feature.md` does not exist → **stop**:
_"Task not found. Invoke the **feature-designer** agent in a new chat to
create it."_

---

## 5. state.md schema

Each `state.md` tracks the task's progress through the TDD lifecycle:

    # Task State

    ## Status
    PHASE: READY

    ## Test Files

    ## Stub Files

    ## Implementation Files

| Phase | Meaning | Set by |
|---|---|---|
| `READY` | Feature designed, no tests yet | `@sda-feature-designer` |
| `RED` | Tests written and failing | `@sda-dev` |
| `GREEN` | Implementation complete, all tests pass | `@sda-dev` |

Agents update only the sections they own using the `edit` tool.
