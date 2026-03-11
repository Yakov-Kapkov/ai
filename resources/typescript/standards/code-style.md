# Code Style and Documentation

**INSTRUCTION FOR AI ASSISTANT**: These are MANDATORY rules for code formatting, readability, and documentation.

## Table of Contents

- [String Formatting](#string-formatting)
- [Clean Code Practices](#clean-code-practices)
- [Comments and Documentation](#comments-and-documentation)
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
- Begin with a short plain-prose title (one sentence, no tag) that names the operation
- Follow with `@summary` for a concise one-line description
- Add a fuller description using `@description` when additional context is needed
- Document parameters and return values using `@param` and `@returns`
- Include examples for complex functionality using `@example`
- Note any exceptions that may be thrown using `@throws`

```typescript
/**
 * Process a document and extract obligations.
 *
 * @summary Extract obligations from a document by ID.
 * @description Validates the document ID, retrieves content from storage, runs the
 * obligations extraction pipeline, and returns a structured result. Throws if the
 * document is missing or processing fails at any stage.
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
