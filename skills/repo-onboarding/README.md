# repo-onboarding

A skill that generates a structured onboarding documentation set for a repository.
Invoked when a new developer (or agent) needs to quickly understand a codebase.
Produces four ready-to-use markdown files covering tooling, architecture, purpose,
and setup.

---

## Outputs

| File | Contents |
|---|---|
| `tools.md` | All development commands — test, lint, type-check, build, run — derived directly from repo files |
| `architecture.md` | Project structure, core components, tech stack, design patterns, and data flow |
| `summary.md` | Plain-language overview: what the repo does, the problem it solves, and its key features |
| `quickstart.md` | Step-by-step setup guide with prerequisites, install commands, verification steps, and common command examples |

---

## Workflow

1. **Ask** — prompts for the output folder location and the user's OS / shell.
2. **tools.md** — scans package manifests, config files, CI/CD, and scripts to document every development command. Each test layer (e.g. frontend, backend) is treated independently.
3. **architecture.md** — maps directories, entry points, data models, services, and integrations.
4. **summary.md** — reads README and main source files to write a concise repo overview.
5. **quickstart.md** — compiles prerequisites, install commands, verification steps, and one example per common command type.
6. **Confirm** — reports the folder where all files were created.

---

## Usage

Invoke the skill with any of the following:

```
Onboard this repo.
```

```
Create onboarding documentation.
```

```
Help me understand this repository from scratch.
```

The skill will ask where to create the files and what shell you are using, then
generate all four documents.

---

## Rules

- Every command is verified against actual repo files before being documented —
  nothing is invented.
- Shell syntax matches the user's environment (bash, zsh, PowerShell, etc.).
- File references use markdown links pointing to the exact file and line range.
- All documents are kept concise — no padding or redundant content.
