# resources

Language-specific standards and toolchain specifications. Each language folder contains coding, testing, and style standards plus a tool-discovery spec.

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

| File | Purpose |
|---|---|
| `tool-discovery.md` | Defines what toolchain to scan for and what to flag as missing |
| `standards/coding-standards.md` | Mandatory rules for production code (types, constants, imports, design principles) |
| `standards/testing-standards.md` | Mandatory rules for test code (structure, mocking, assertions) |
| `standards/code-style.md` | Formatting, naming, and documentation comment rules |

---

## Adding a new language

Create a folder matching the language name (as it would be inferred from the project's manifest file — e.g. `package.json` → `typescript`, `pyproject.toml` → `python`) and populate it with the same four files.
