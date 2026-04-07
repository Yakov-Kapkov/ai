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

## 2. Standards

Coding standards are defined globally and may be overridden by
workspace-local standards. If the workspace contains local coding
standards, those take precedence over global defaults.

---

## 3. Locate the task

The user provides a **task name** (e.g. `001. snowflake-config-provider`).
Task folders live at `./.dev-assistant/tasks/<task-name>/` and are numbered
sequentially with a three-digit prefix (e.g. `001. `, `002. `, `003. `).

Each task folder contains:

| File | Created by | Purpose |
|---|---|---|
| `task.md` | `@sda-task` | Task specification with test scenarios |
| `state.md` | `@sda-task` | Task progress — updated by each agent |

If the task folder or `task.md` does not exist → **stop**:
_"Task not found. Invoke the **sda-task** agent in a new chat to
create it."_

---

## 4. state.md schema

Each `state.md` tracks the task's progress per slice:

    # Task State

    ## Slices
    1. {Slice name} — PENDING — {N} scenarios
    2. {Slice name} — PENDING — {N} scenarios

| State | Meaning | Set by |
|---|---|---|
| `PENDING` | Not started | `@sda-task` |
| `RED` | Tests written and failing | `@sda-dev` |
| `GREEN` | Tests passing | `@sda-dev` |
| `DONE` | Slice complete and approved | `@sda-dev` |

`sda-dev` updates each slice's state and appends file paths as it
progresses.
