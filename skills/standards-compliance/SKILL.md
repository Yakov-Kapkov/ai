---
name: standards-compliance
description: "Enforce project coding standards on all produced code changes. Always read at the start of any implementation task. Contains the authoritative rule content from coding-standards.md, testing-standards.md, and code-style.md. Agent instructions summarize standards behavior only — the actual rules are in this skill and must be loaded explicitly.md. Resolves conflicts between task specs and standards. Defines global/local priority and scope-specific application rules."
---

# Standards Compliance Enforcement

Behavioral rules for enforcing coding standards on all produced code.
Language-agnostic — works with any language that has standards files.

## When to Use

- Writing or modifying **any** file: production code, tests, stubs,
  integration wiring
- Resolving conflicts between a task spec and coding standards
- Validating code examples in task specifications

---

## Standards: Global and Local

### Two layers

| Layer | Location | Scope |
|---|---|---|
| **Global** | Bundled with this skill: `./standards/{language}/` | Baseline rules for any project |
| **Local** | Workspace-specific, discovered automatically | Project-specific overrides and additions |

### Priority — local wins

When a rule exists in **both** global and local standards, the **local
version takes precedence**. Local standards may:
- Override a global rule (e.g., stricter naming convention)
- Add project-specific rules not covered globally
- Relax a global rule when justified for this project

**Merge strategy:**
1. Load global standards for the detected language
2. If local standards are present in the workspace (discovered via
   workspace documentation, readme files, or agent configuration),
   load them as well
3. For any conflicting rule, apply the local version
4. Rules that exist only in global → apply as-is
5. Rules that exist only in local → apply as-is

### Global standards file structure

Global standards are bundled as skill resources:

```
standards/
├── python/
│   ├── coding-standards.md
│   ├── testing-standards.md
│   └── code-style.md
├── typescript/
│   ├── coding-standards.md
│   ├── testing-standards.md
│   └── code-style.md
└── {language}/          ← add new languages here
    └── ...
```

New languages are added by creating a `standards/{language}/` folder
with the applicable standards files.

### Local standards discovery

Local standards are not configured explicitly. They are discovered
automatically when the workspace contains coding standards files
referenced by its documentation (readme files, agent configuration,
etc.). If the agent can locate workspace-specific standards, those
are used as local standards and take precedence over global ones.
If no local standards are found, global standards apply as the
sole source.

---

## Enforcement Rules

### 1. Universal compliance — no exceptions

**All produced or modified code must comply with all loaded standards.**

This applies to every file type: stubs, tests, implementation, and
integration changes alike. Write compliant code from the start —
do not write non-compliant code and fix it after.

### 2. Conflict resolution — standards win over task specs

Task documents (`task.md`, user descriptions, attached specs) are
**behavioral specs, not code specs.** Code snippets and type definitions
illustrate intent — not authorized final syntax.

When any detail in a task document conflicts with loaded standards:

| Conflict | Resolution |
|---|---|
| Magic strings/numbers | Use named constants per standards |
| Naming conventions | Follow standards |
| Type patterns | Follow standards |
| Import organization | Follow standards |
| Docstring format | Follow standards |

**Adapt the implementation to satisfy both the task's behavioral intent
and every applicable standard.**

### 3. Scope-specific application

Apply the relevant standards files based on what you're writing:

- **Production code** — `coding-standards.md` + `code-style.md`
- **Test code** — `testing-standards.md` + `code-style.md`
- **Stubs** — all production standards apply; function/method bodies
  throw unambiguous "not implemented" error; only export symbols that
  tests reference

### 4. Task specification validation

When reviewing or producing code examples in task documents (`task.md`):

- **Executable code blocks** (imports, function signatures, class
  definitions) must comply with coding standards
- **Behavioral descriptions** (Given/When/Then prose, acceptance
  criteria text) are exempt — they describe intent, not code
- Flag non-compliant examples and suggest corrections

---

## How to Evaluate Compliance

1. Identify the file type (production, test, stub) to determine which
   standards files apply (see scope-specific application above)
2. Read standards files if not already fully in context
3. Compare produced code against all applicable rules
4. Do not re-derive rules already in the standards — read the standard,
   apply it directly
5. Report result:
   - **✅ All standards met**, or
   - **List of fixes applied** — file path and what changed for each
