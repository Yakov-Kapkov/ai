# Code Style and Documentation

**INSTRUCTION FOR AI ASSISTANT**: These are MANDATORY rules for code formatting, readability, and documentation.

## Table of Contents

- [String Formatting](#string-formatting)
- [Clean Code Practices](#clean-code-practices)
- [Comments and Documentation](#comments-and-documentation)
- [File Header Comment](#file-header-comment-mandatory)
- [Comments: Explain "Why", Not "What"](#comments-explain-why-not-what)
- [Anti-Patterns to Avoid](#anti-patterns-to-avoid)

## String Formatting

### String Formatting: Quote Variables in Messages

**RULE**: When embedding variables in error messages, log messages, or user-facing strings, wrap the variable in single quotes.

**Why**: Makes variable boundaries visible, especially important for UUIDs, file paths, and user input that might contain spaces or special characters.

```typescript
// ✅ CORRECT: Variables enclosed in apostrophes
throw new Error(`Flow '${flowId}' not found`);
throw new Error(`File '${filePath}' does not exist`);
logger.error(`Failed to process flow`, { flowId, status: flowStatus });

// ❌ AVOID: Variables without apostrophes
throw new Error(`Flow ${flowId} not found`);
throw new Error(`File ${filePath} does not exist`);
```

**When to apply:**
- Error messages with variable values
- Log messages with embedded variables
- User-facing messages with dynamic content
- Debug output with identifiers

**Exception:** Structured logging key-value pairs don't need quotes around values:
```typescript
// ✅ CORRECT: Structured logging
logger.info("Processing flow", { flowId, status });

// ❌ AVOID: Quotes in structured logging values
logger.info("Processing flow", { flowId: `'${flowId}'` });  // Don't do this
```

## Clean Code Practices

### Clean Code Practices

- **Descriptive Naming**: Names clearly express intent
- **Small Functions**: Single responsibility, <20 lines
- **Type Annotations (MANDATORY)**: Full type annotations for ALL function/method parameters and return types (see `@coding-standards.md`)
- **Documentation**: JSDoc/TSDoc comments with examples for public functions
- **Error Handling**: Defensive programming with custom error classes
- **Import Organization**: All imports at file top following standard conventions (see `@coding-standards.md`)

## Comments and Documentation

### File Header Comment (MANDATORY)

**RULE**: Every file MUST begin with a concise block comment (max 5 lines) summarizing the file's purpose, responsibility, and key constraints. Write it for a developer reading the file for the first time.

**What to include:**
- What this module **is** (one sentence)
- Its primary **responsibility** or role in the system
- Key **constraints or design decisions** worth knowing upfront (e.g. "thin controller — no business logic", "singleton pattern")

```typescript
/**
 * Route handlers for the Admin Logs API.
 *
 * Thin controller: extracts params, validates input, delegates to AdminLogsService.
 * No business logic here — authentication is handled by authenticateSnowflakeAccess middleware.
 */
```

```typescript
/**
 * Snowflake data access layer for admin chat logs.
 *
 * Queries COCOUNSEL_BASENJI_PUBLIC_NC_CHATS_VW and maps raw uppercase column names
 * to the AdminLog domain shape. All SQL lives here — no queries outside this class.
 */
```

**Rules:**
- ✅ Max 5 lines of text (not counting the `/**` and `*/` delimiters)
- ✅ Plain prose — no `@param`, `@returns`, or other JSDoc tags
- ✅ Written at the **very top of the file**, before any imports
- ❌ Do not restate the filename or list every export
- ❌ Do not describe implementation details — describe purpose and constraints
- ❌ **Never use `//` line comments for the file header.** The file header MUST be a JSDoc block (`/** ... */`). `//` comments are only for inline code remarks.

```typescript
// ❌ WRONG — line comments are not a valid file header
// StringUtils — utility class for string manipulation operations.
// Implements the `invert` method for reversing strings.
// Author: tdd-implementer agent | Date: 2026-02-25

// ✅ CORRECT — JSDoc block comment as file header
/**
 * Utility class for general-purpose string manipulation.
 *
 * Stateless helper — all methods are pure functions with no side effects.
 */
```

---

### Comments: Explain "Why", Not "What"

**✅ WRITE comments that explain:**
- WHY this algorithm/approach was chosen
- Non-obvious design decisions and their rationale
- Edge cases and constraints
- Business logic context

**❌ DON'T write comments that:**
- Excuse magic numbers/strings (use named constants instead)
- Justify skipping refactoring (refactor instead)
- Defend standard violations (fix the code instead)
- Explain obvious code (the code should be self-explanatory)

### JSDoc/TSDoc Standards

**All public classes, functions, and methods must have JSDoc comments:**
- Describe what the code does (not how)
- Document parameters and return values using `@param` and `@returns`
- Include examples for complex functionality using `@example`
- Note any exceptions that may be thrown using `@throws`

```typescript
/**
 * Process a document and extract obligations.
 * 
 * @param documentId - Unique identifier for the document
 * @param content - Raw document content to process
 * @param options - Optional processing configuration
 * @returns Processing result with extracted obligations
 * @throws {DocumentNotFoundError} If document doesn't exist
 * @throws {ProcessingError} If processing fails
 * 
 * @example
 * ```typescript
 * const result = await processDocument('doc-123', content, { timeout: 5000 });
 * console.log(result.obligations);
 * ```
 */
async function processDocument(
  documentId: string,
  content: string,
  options?: ProcessingOptions
): Promise<ProcessingResult> {
  // Implementation
}
```

### Comment Quality Checklist
- [ ] Comments explain "why" and "what", not "how"
- [ ] No comments justifying magic numbers (use named constants instead)
- [ ] No comments apologizing for bad code (refactor the code instead)
- [ ] No TODO comments without refactoring the code first
- [ ] Complex logic has explanatory comments
- [ ] All public APIs have comprehensive JSDoc comments
- [ ] Comments are up-to-date with the code

## Anti-Patterns to Avoid

### Anti-Patterns to Avoid

- **Magic Numbers/Strings**: Hardcoded values without constants (see `@coding-standards.md`)
- **God Objects**: Classes doing too many things
- **Deep Nesting**: >3 levels of indentation
- **Tight Coupling**: Classes knowing too much about internals
- **Untested Code**: Missing unit tests (see `@development-workflow.md`)
- **Scattered Imports**: Imports scattered throughout code instead of at file top (see `@coding-standards.md`)
- **Any Types**: Using `any` instead of proper types (see `@coding-standards.md`)
