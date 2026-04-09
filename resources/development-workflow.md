# Development Workflow

## Table of Contents

- [Test-Driven Development (TDD)](#test-driven-development-tdd)
- [Development Workflow](#development-workflow)
- [Code Review Criteria](#code-review-criteria)
- [Quality Gates](#quality-gates)

## Test-Driven Development (TDD)

**MANDATORY WORKFLOW**: You MUST use Test-Driven Development for ALL code you write.

**What is TDD**: A development methodology where tests drive code design. Tests define what the code must do BEFORE you write the implementation.

**The only acceptable workflow**: Test FIRST → Implementation SECOND → Refactor THIRD.

### The TDD Cycle (Follow This Order)
1. **RED**: Write a failing test that describes what you want the code to do
2. **GREEN**: Write the simplest code that makes the test pass
3. **REFACTOR**: Clean up the code while keeping all tests passing

### When to Use TDD
- ✅ **ALWAYS** - Every new feature requires tests first
- ✅ **ALWAYS** - Every bug fix requires a failing test first, then the fix
- ✅ **ALWAYS** - Before refactoring, ensure tests are passing; after refactoring, ensure tests still pass

### Absolute Requirements
- ✅ **ALWAYS write the test BEFORE writing any implementation**
- ✅ Each test verifies ONE specific behavior only
- ✅ New code MUST have >95% test coverage
- ❌ **FORBIDDEN: Writing implementation first, then adding tests**
- ❌ **FORBIDDEN: Skipping tests for any reason**

## Development Workflow

### Your Development Workflow

**FOLLOW THIS ORDER**:
1. **Plan**: Design the component architecture and interfaces
2. **RED**: Write a failing test that defines the expected behavior
3. **GREEN**: Write minimal code to make the test pass
4. **REFACTOR**: Clean up code while keeping all tests passing
5. **Document**: Add documentation comments (docstrings, TSDoc, etc.)
6. **Verify**: Check that you followed TDD and all coding standards

## Code Review Criteria

1. **Functionality**: Works correctly, handles edge cases
2. **Standards**: Follows all guidelines in the language-specific coding standards
3. **Magic Values**: Zero hardcoded numbers/strings in production code
4. **Type Safety**: Proper type annotations, no untyped parameters
5. **SOLID Principles**: Clean design patterns
6. **Documentation**: Clear, up-to-date documentation comments

## Quality Gates

- All tests must pass
- >95% code coverage for new code
- Static type checker passes in strict mode (mypy, tsc, etc.)
- Zero magic numbers/strings in production code, controlled usage in test code
