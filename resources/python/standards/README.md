# Copilot Coding Standards - Index

**Purpose**: This directory contains AI assistant instructions for maintaining code quality and consistency across the project.

## Quick Navigation

| File | Purpose | When to Use |
|------|---------|-------------|
| **[@coding-standards.md](coding-standards.md)** | Core technical rules for production code | Writing production code: types, constants, imports |
| **[@testing-standards.md](testing-standards.md)** | How to write quality tests | Writing any test code: fixtures, AAA, parameterization |
| **[@code-style.md](code-style.md)** | Formatting and documentation rules | Formatting code, writing comments/docstrings |
| **[@development-workflow.md](development-workflow.md)** | TDD process and quality gates | Starting new work, understanding TDD workflow |

## Decision Tree: Which File Do I Need?

```
What are you doing?
│
├─ Writing production code?
│  ├─ Need type hints, constants, imports? → @coding-standards.md
│  └─ Need formatting, comments, docs? → @code-style.md
│
├─ Writing tests?
│  ├─ Need test structure, fixtures, parameterization? → @testing-standards.md
│  └─ Starting fresh? → @development-workflow.md (for TDD process)
│
├─ Starting a new feature?
│  └─ Read @development-workflow.md first (TDD cycle)
│
└─ Doing code review?
   └─ Check all four files' checklists
```

## File Summaries

### 1. coding-standards.md
**Core technical rules for production code**
- SOLID principles
- Type annotations (MANDATORY for all parameters)
- Dataclasses vs dictionaries
- Magic number prevention
- Import organization (PEP 8)

### 2. testing-standards.md
**How to write quality tests**
- Fixture usage (eliminate duplication)
- AAA structure (Arrange-Act-Assert)
- Test parameterization
- Test duplication detection
- Test constants guidelines
- Mocking best practices

### 3. code-style.md
**Formatting and documentation**
- Module docstring (MANDATORY: max 5-line summary at top of every file)
- String formatting (quote variables)
- Clean code practices
- Comments (explain "why", not "what")
- Docstring standards
- Anti-patterns to avoid

### 4. development-workflow.md
**Process and methodology**
- TDD (Test-Driven Development) - MANDATORY
- RED-GREEN-REFACTOR cycle
- Development workflow (6 steps)
- Code review criteria
- Quality gates

## For AI Assistants (Copilot)

**Context loading strategy**:
- **Production code context**: Load `@coding-standards.md` + `@code-style.md`
- **Test code context**: Load `@testing-standards.md` + `@development-workflow.md`
- **New feature context**: Load `@development-workflow.md` first

**All rules marked MANDATORY are non-negotiable.**

## For Human Developers

**Onboarding**: Start with `@development-workflow.md` to understand TDD, then explore specific files as needed.

**Quick reference**: Bookmark this README and use the decision tree above.

**Code review**: Use checklists from each relevant file.

**Disputes**: Cite specific file + section in PR discussions.
