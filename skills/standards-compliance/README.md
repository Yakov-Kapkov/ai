# Standards Compliance — Skill

A Copilot skill that enforces coding standards on all produced code. It ships with **global** standards for multiple languages and automatically discovers **local** (project-specific) overrides at runtime.

---

## What's Inside

| File / Folder | Purpose |
|---|---|
| `SKILL.md` | Skill definition — behavioral rules for standards enforcement |
| `standards/{language}/` | Global standards files bundled with the skill |

Each language folder contains three standards files:

| File | Scope |
|---|---|
| `coding-standards.md` | Production-code rules (types, error handling, naming, structure) |
| `testing-standards.md` | Test-code rules (arrange/act/assert, mocking, coverage) |
| `code-style.md` | Style rules (formatting, comments, imports) |

---

## Setup

### 1. Copy the skill folder

Copy the `skills/standards-compliance/` folder into your target project's Copilot skills directory (typically `.github/copilot/skills/` or wherever your workspace loads skills from):

```
<your-project>/
└── .github/
    └── copilot/
        └── skills/
            └── standards-compliance/
                ├── SKILL.md
                └── standards/
                    ├── python/
                    │   ├── coding-standards.md
                    │   ├── testing-standards.md
                    │   └── code-style.md
                    ├── typescript/
                    │   ├── coding-standards.md
                    │   ├── testing-standards.md
                    │   └── code-style.md
                    └── {language}/          ← more languages can be added
                        └── ...
```

### 2. Copy language-specific standards from `resources/`

The language folders under `standards/{language}` are sourced from the **`resources/{language}/standards`** folder in the root of this repository. During installation, copy only the languages you need:

### 3. Verify the result

After setup, the `standards/` folder inside the skill should contain one sub-folder per language you support:

```
standards-compliance/
├── SKILL.md
├── README.md
└── standards/
    └── {your-language}/
        ├── coding-standards.md
        ├── testing-standards.md
        └── code-style.md
```

---

## Usage

The skill activates automatically when Copilot produces or modifies code. No explicit invocation is needed — any agent that writes production code, tests, stubs, or integration changes will apply the loaded standards.

### How standards are resolved

1. **Global standards** are read from the `standards/{language}/` folders bundled with this skill.
2. **Local standards** are discovered automatically if the workspace contains its own coding-standards files (referenced by readme files, agent configuration, etc.).
3. When a rule exists in both global and local, **local wins**.

### Scope-specific application

| What you're writing | Standards applied |
|---|---|
| Production code | `coding-standards.md` + `code-style.md` |
| Test code | `testing-standards.md` + `code-style.md` |
| Stubs | All production standards |

---

## Adding a New Language

1. Create `resources/{language}/standards/` in this repository with:
   - `coding-standards.md`
   - `testing-standards.md`
   - `code-style.md`
2. Copy the new folder into the installed skill's `standards/` directory:
   ```
   cp -r resources/{language}/standards skills/standards-compliance/standards/{language}
   ```
3. The skill will pick up the new language automatically — no changes to `SKILL.md` required.
