# Bootstrap — initialization for `sda-dev` agent

This file is read by `sda-dev` at the start of every conversation.

Follow these steps before doing any implementation work.

---

## 1. Detect language + verify tooling

Read all three files **in one parallel batch**:
- `./package.json` (or other manifest — see table below)
- `./.dev-assistant/project-tools.md`
- `./.dev-assistant/project-config.json`

**Language detection** — determine from the manifest file:

| Marker file | Language |
|---|---|
| `package.json` | `typescript` |
| `pyproject.toml` or `requirements.txt` | `python` |
| Other manifest/config files | Infer from context |

If no marker is found or the language is ambiguous, ask: _"Could not detect
the project language. Please specify."_

**Project tooling check:**

If `project-tools.md` is missing → **HARD STOP. No exceptions. No workarounds.
Do not search for it elsewhere. Do not read project manifest files as a substitute.
Do not reason about what the user "probably wants". Do not continue.**
Print exactly: _"Project not initialized.
Invoke the **init** agent in a new chat to set up project tooling."_
Then end your response. Nothing else.

If `project-config.json` is missing → continue with defaults
(`tests.coverage.enabled: true`, `tests.coverage.threshold: 95`).

---

## 2. Resolve CONFIG_PATHS

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

## 3. Locate the task

The user provides a **task name** (e.g. `01-snowflake-config-provider`).
Task folders live at `./.dev-assistant/tasks/<task-name>/` and are numbered
sequentially with a two-digit prefix (e.g. `01-`, `02-`, `03-`).

Each task folder contains:

| File | Created by | Purpose |
|---|---|---|
| `task.md` | `@task-designer` | Task specification with test scenarios |
| `state.md` | `@task-designer` | Task progress — updated by each agent |

If the task folder or `task.md` does not exist → **stop**:
_"Task not found. Invoke the **task-designer** agent in a new chat to
create it."_

---

## 4. state.md schema

Each `state.md` tracks the task's progress per slice:

    # Task State

    ## Slices
    1. {Slice name} — PENDING
    2. {Slice name} — PENDING

| State | Meaning | Set by |
|---|---|---|
| `PENDING` | Not started | `@sda-task-designer` |
| `RED` | Tests written and failing | `@sda-dev` |
| `GREEN` | Tests passing | `@sda-dev` |
| `DONE` | Slice complete and approved | `@sda-dev` |

`sda-dev` updates each slice's state and appends file paths as it
progresses.
