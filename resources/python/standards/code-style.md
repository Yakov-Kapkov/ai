# Code Style and Documentation

**INSTRUCTION FOR AI ASSISTANT**: These are MANDATORY rules for code formatting, readability, and documentation.

## String Formatting (MANDATORY)

**RULE**: Wrap variables in single quotes in error/log/user-facing messages.

**Why**: Makes variable boundaries visible, especially for UUIDs, file paths, user input with spaces/special chars.

```python
# ✅ CORRECT
raise ValueError(f"Flow '{flow_id}' not found")
raise ValueError(f"File '{file_path}' does not exist")
logger.error("Failed to process", flow_id=flow_id)  # Structured logging - no quotes in values

# ❌ WRONG
raise ValueError(f"Flow {flow_id} not found")
logger.info("Processing", flow_id=f"'{flow_id}'")  # Don't quote structured logging values
```

## Clean Code Practices

- **Descriptive Naming**: Names clearly express intent
- **Small Methods**: Single responsibility, <20 lines
- **Type Hints**: Full annotation - see `@coding-standards.md`
- **Documentation**: Docstrings with examples for public APIs
- **Error Handling**: Defensive programming with custom exceptions
- **Import Organization**: All imports at file top - see `@coding-standards.md`

## Comments and Documentation

### Module Docstring (MANDATORY)

**RULE**: Every file MUST begin with a module-level docstring (max 5 lines) summarizing the file's purpose, responsibility, and key constraints. Write it for a developer reading the file for the first time.

**What to include:**
- What this module **is** (one sentence)
- Its primary **responsibility** or role in the system
- Key **constraints or design decisions** worth knowing upfront

```python
"""Route handlers for the Admin Logs API.

Thin controller: extracts params, validates input, delegates to AdminLogsService.
No business logic here — authentication is handled by authenticate_snowflake_access middleware.
"""
```

```python
"""Snowflake data access layer for admin chat logs.

Queries COCOUNSEL_BASENJI_PUBLIC_NC_CHATS_VW and maps raw uppercase column names
to the AdminLog domain shape. All SQL lives here — no queries outside this class.
"""
```

**Rules:**
- ✅ Max 5 lines of text (not counting the `"""` delimiters)
- ✅ Plain prose — no `:param:`, `:returns:`, or other Sphinx/Google tags
- ✅ Placed at the **very top of the file**, before any imports
- ❌ Do not restate the filename or list every export
- ❌ Do not describe implementation details — describe purpose and constraints

---

### Comments: Explain "Why", Not "What"

**✅ Comments explain**: WHY (algorithm choice, design decisions), edge cases, business logic context  
**❌ Don't comment**: Magic numbers (use constants), bad code (refactor), obvious code

**Docstrings required**: All public classes/methods/functions describing what (not how), parameters, returns, exceptions, examples for complex functionality

## Anti-Patterns to Avoid

- **Magic Numbers/Strings**: Use named constants - see `@coding-standards.md`
- **God Objects**: Classes doing too many things
- **Deep Nesting**: >3 levels of indentation
- **Tight Coupling**: Classes knowing too much about internals
- **Untested Code**: Missing unit tests - see `@development-workflow.md`
- **Inline Imports**: See `@coding-standards.md`
- **Orphaned Constants**: Never used (delete), used once (make local), or partially used (complete refactoring)

```python
# ❌ Orphaned constant examples
UNUSED_VALUE = 42  # Never referenced - DELETE

SINGLE_USE = 30  # Used once - make local
def test_x(self):
    result = process(timeout=SINGLE_USE)

MOCK_PATH = "/tmp/test.docx"  # Partial - used in 1 of 10 places
@pytest.fixture
def mock_file():
    return Document(path=MOCK_PATH)  # Uses constant
def test_load(self):
    doc = load("/tmp/test.docx")  # Still hardcoded! Complete refactoring or revert
```
