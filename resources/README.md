# Coding Standards — Index

**Purpose**: AI assistant instructions for maintaining code quality and consistency. Standards are split by language; shared workflow rules live here.

---

## Structure

```
resources/
├── common-standards.md              ← language-agnostic rules
├── development-workflow.md          ← shared, language-independent
├── java/
│   ├── tool-discovery.md
│   └── standards/
│       ├── coding-standards.md
│       ├── testing-standards.md
│       └── code-style.md
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

## Quick Navigation

| File | Purpose | When to Use |
|------|---------|-------------|
| **[common-standards.md](common-standards.md)** | Language-agnostic rules (SOLID, AAA, behavioral testing) | Loaded for all languages automatically |
| **[development-workflow.md](development-workflow.md)** | TDD process, review criteria, quality gates | Starting new work, understanding TDD workflow |
| **coding-standards.md** | Core technical rules for production code | Writing production code: types, constants, imports |
| **testing-standards.md** | How to write quality tests | Writing any test code: structure, AAA, mocking |
| **code-style.md** | Formatting and documentation rules | Formatting code, writing comments/docs |
| **tool-discovery.md** | Toolchain scanning spec | Detecting missing tools |

## Decision Tree: Which File Do I Need?

```
What are you doing?
│
├─ Starting a new feature or fixing a bug?
│  └─ Read development-workflow.md first (TDD cycle)
│
├─ Writing production code?
│  ├─ Need types, constants, imports? → coding-standards.md (for your language)
│  └─ Need formatting, comments, docs? → code-style.md (for your language)
│
├─ Writing tests?
│  └─ Need test structure, setup, mocking? → testing-standards.md (for your language)
│
└─ Doing code review?
   └─ Check checklists in all relevant files
```

## File Summaries

### development-workflow.md (shared)
**Process and methodology — language-independent**
- TDD (Test-Driven Development) — MANDATORY
- RED → GREEN → REFACTOR cycle
- Development workflow steps
- Code review criteria
- Quality gates

### coding-standards.md

**Java** (`java/standards/`):
- Type annotations (MANDATORY, NEVER use raw types or `Object`)
- Records/classes with Bean Validation vs plain Maps
- Optional for nullable returns
- Enums over string/integer constants
- Magic number/string prevention
- Import organization (no wildcards, grouped by origin)

**TypeScript** (`typescript/standards/`):
- SOLID principles
- Type annotations (MANDATORY, NEVER use `any`)
- Interfaces/Types vs plain objects
- Zod schemas for runtime validation
- Magic number/string prevention
- Import organization (ES6 modules)

**Python** (`python/standards/`):
- SOLID principles
- Type annotations (MANDATORY for all parameters)
- Pydantic models / dataclasses vs dictionaries
- Magic number/string prevention
- Import organization (PEP 8)

### testing-standards.md

**Java** (`java/standards/`):
- `@BeforeEach` setup and helper functions
- Test parameterization (`@ParameterizedTest`, `@CsvSource`, `@MethodSource`)
- Mocking best practices (Mockito `@Mock`, `@InjectMocks`, `mockStatic`)

**TypeScript** (`typescript/standards/`):
- Test setup functions and utilities
- Test parameterization (`it.each` / `describe.each`)
- Mocking best practices (`vi.spyOn`, `vi.mock`)

**Python** (`python/standards/`):
- Fixture usage (eliminate duplication)
- Test parameterization (`@pytest.mark.parametrize`)
- Mocking best practices (`patch.object`)

### code-style.md

**Java** (`java/standards/`):
- String formatting (quote variables)
- No file-level block comments (class Javadoc serves as file doc)
- Javadoc standards (Summary + description + `@param` / `@return` / `@throws`)

**TypeScript** (`typescript/standards/`):
- String formatting (quote variables)
- Clean code practices
- Comments (explain "why", not "what")
- TSDoc standards (Title + @summary + @description)
- Anti-patterns to avoid (orphaned constants, etc.)

**Python** (`python/standards/`):
- String formatting (quote variables)
- Clean code practices
- Module docstring (MANDATORY: max 5 lines at top of every file)
- Docstring standards (Summary, Args, Returns, Raises)
- Comments (explain "why", not "what")
- Anti-patterns to avoid (orphaned constants, etc.)

---

## For AI Assistants (Copilot)

**Context loading strategy**:
- **New feature**: Load `development-workflow.md` first
- **Production code**: Load `coding-standards.md` + `code-style.md` for the target language
- **Test code**: Load `testing-standards.md` for the target language

**All rules marked MANDATORY are non-negotiable.**

## For Human Developers

**Onboarding**: Start with `development-workflow.md` to understand TDD, then explore language-specific files as needed.

**Quick reference**: Bookmark this README and use the decision tree above.

**Code review**: Use checklists from each relevant file.

**Disputes**: Cite specific file + section in PR discussions.

## Framework-Specific Notes

**Java**: Examples use JUnit 5 and Mockito. Ensure a static analysis tool (Checkstyle, SpotBugs, or Error Prone) is configured. Use records for immutable value objects.

**TypeScript**: Examples use Jest/Vitest syntax but principles apply to Mocha or other frameworks. Ensure `strict: true` in `tsconfig.json`. ESLint should enforce these standards where possible.

**Python**: Examples use pytest. Ensure mypy strict mode is enabled.

---

## Adding a new language

Create a folder matching the language name (as it would be inferred from the project's manifest file — e.g. `package.json` → `typescript`, `pyproject.toml` → `python`) and populate it with `tool-discovery.md` and a `standards/` folder containing `coding-standards.md`, `testing-standards.md`, and `code-style.md`.
