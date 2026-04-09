# Common Standards

Language-agnostic rules. Loaded alongside every language's standards files.

## Table of Contents

- [SOLID Design Principles](#solid-design-principles)
- [Unit Test Scope](#unit-test-scope)
- [Behavioral Testing](#behavioral-testing)
- [Test Structure: AAA](#test-structure-aaa)
- [Test Constants](#test-constants)
- [Derive Expected Values from Mocked Data](#derive-expected-values-from-mocked-data)
- [Clean Code Practices](#clean-code-practices)
- [Comments: Explain Why Not What](#comments-explain-why-not-what)
- [Anti-Patterns](#anti-patterns)

## SOLID Design Principles

- **Single Responsibility**: Each class/function has one clear purpose
- **Open/Closed**: Extensible without modification
- **Liskov Substitution**: Derived classes are substitutable for base classes
- **Interface Segregation**: Clean, focused interfaces
- **Dependency Inversion**: Depend on abstractions, not implementations

## Unit Test Scope

**RULE**: Unit tests MUST test only ONE module. All other modules MUST be mocked.

**What to mock:**
- External API clients, database connections, file system operations
- Other modules from your codebase
- Time/date functions (for deterministic tests)

**What NOT to mock:**
- Standard library data structures
- The specific module you're testing
- Simple value objects and dataclasses/interfaces

**No real network I/O:** Unit tests MUST NOT make real HTTP requests,
open sockets, or connect to databases. Every external endpoint must
be mocked. A test that hangs because no server is reachable is a
test-isolation violation, not a server problem.

## Behavioral Testing

**RULE**: Tests MUST verify **observable behavior** (inputs → outputs,
side effects, responses), NOT internal implementation details.

**Red flags — avoid asserting on:**
- SQL text content or bind parameter positions
- Internal method call counts (unless the call *is* the behavior)
- Private/internal state
- Argument shapes passed between internal layers

**Assert instead on:**
- HTTP status codes and response bodies
- Return values from public APIs
- Observable side effects (data written, events emitted, external calls made)
- Error messages shown to the user

## Test Structure: AAA

**RULE**: Every test MUST have three sections marked with exact comments: `Arrange`, `Act`, `Assert`.

No extra text after the comment keyword.

## Test Constants

**LOCAL constants**: Expected/assertion values used in ONE test only.
**DIRECT literals**: In parameterize/`it.each` arrays, mock-only values, simple setup.
**GLOBAL/MODULE constants**: Value asserted in 2+ tests, shared fixture values, test infrastructure.

**Avoid:**
- Global for single-test values
- Math with globals (`GLOBAL + 1`)
- Globals just for parameterize
- Globals for coincidentally identical values testing different things

**Atomic replacement**: When creating a constant, replace ALL occurrences or don't create it.

## Derive Expected Values from Mocked Data

**RULE**: Every assertion value originating from a mock, fixture, or
test constant MUST be referenced from that source — never re-typed
as a literal. Applies to all mock-originated values: fields, computed
strings, IDs, timestamps, numbers, config values.

**Why**: If the mock value changes, the assertion breaks immediately —
catching the mismatch at edit time instead of producing a false-green test.

## Clean Code Practices

- **Descriptive Naming**: Names clearly express intent
- **Small Functions/Methods**: Single responsibility, <20 lines
- **Type Annotations**: Full annotation — see language `coding-standards.md`
- **Documentation**: Docstrings/TSDoc for public APIs
- **Error Handling**: Defensive programming with custom exceptions
- **Import Organization**: All imports at file top — see language `coding-standards.md`

## Comments: Explain Why Not What

**Write comments that explain**: WHY (algorithm choice, design decisions),
edge cases, business logic context.

**Do not comment**: Magic numbers (use constants), bad code (refactor),
obvious code, standard violations (fix the code).

## Anti-Patterns

- **Magic Numbers/Strings**: Use named constants — see language `coding-standards.md`
- **God Objects**: Classes doing too many things
- **Deep Nesting**: >3 levels of indentation
- **Tight Coupling**: Classes knowing too much about internals
- **Untested Code**: Missing unit tests
- **Orphaned Constants**: Never used (delete), used once (make local), or partially used (complete refactoring)
