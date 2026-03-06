# resources

Language-specific configuration files shared across agents and prompts in this repo.
Each language folder contains coding/testing/style standards and a tool-discovery spec.
They are consumed by the `tdd-workflow` agent suite (via `.tdd-workflow/resources/`) and
referenced directly by the `prompts/` system (via `standards/{language}/`).

---

## Structure

```
resources/
├── python/
│   ├── tool-discovery.md
│   └── standards/
│       ├── coding-standards.md
│       ├── testing-standards.md
│       └── code-style.md
└── typescript/
    ├── tool-discovery.md
    └── standards/
        ├── coding-standards.md
        ├── testing-standards.md
        └── code-style.md
```

---

## Files

| File | Used by | Purpose |
|---|---|---|
| `tool-discovery.md` | `tdd-tool-discovery` | Defines what toolchain to scan for and what to flag as missing |
| `standards/coding-standards.md` | `tdd-implementer`, `tdd-quality-gate` | Mandatory rules for production code (types, constants, imports, design principles) |
| `standards/testing-standards.md` | `tdd-test-writer`, `tdd-quality-gate` | Mandatory rules for test code (structure, mocking, assertions) |
| `standards/code-style.md` | all code agents | Formatting, naming, and documentation comment rules |

---

## How these files are used

**`tdd-workflow` agents** — When the orchestrator runs against a project, the relevant
language folder is copied into `.tdd-workflow/resources/` at the project root (see the
[tdd-workflow setup guide](../agents/tdd-workflow/README.md#setup)). Agents read the
files using exact paths — nothing is searched for at runtime.

**`prompts/` system** — `method-of-work.md` routes each task type to the standards
files under `standards/{language}/` directly. These files are read in full before any
coding, bug-fix, refactoring, or code-review task begins.

To add support for a new language, create a new folder matching the language name
(as it would be inferred from the project's manifest file) and populate it with the
same four files.
