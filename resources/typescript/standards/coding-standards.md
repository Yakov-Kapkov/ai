# Coding Standards

**INSTRUCTION FOR AI ASSISTANT**: These are MANDATORY technical rules for writing production TypeScript code. Every rule marked MANDATORY is non-negotiable.

## Table of Contents

- [Core Principles](#core-principles)
- [Type Safety and Strongly-Typed Patterns](#type-safety-and-strongly-typed-patterns)
- [Magic Number/String Prevention](#magic-numberstring-prevention)
- [Import Organization](#import-organization)

## Core Principles

### SOLID Design Principles
- **Single Responsibility**: Each class/function has one clear purpose
- **Open/Closed**: Extensible without modification
- **Liskov Substitution**: Derived classes are substitutable for base classes
- **Interface Segregation**: Clean, focused interfaces
- **Dependency Inversion**: Depend on abstractions, not implementations

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
- ✅ **NEVER write production code without a failing test first**
- ✅ Each test verifies ONE specific behavior only
- ✅ New code MUST have >95% test coverage
- ✅ All tests MUST pass before and after refactoring
- ❌ **FORBIDDEN: Writing implementation first, then adding tests**
- ❌ **FORBIDDEN: Skipping tests for any reason**

## Type Safety and Strongly-Typed Patterns

### Data Models: Use Zod or TypeScript Interfaces (MANDATORY)

**RULE**: For ALL data models, API models, and configuration objects, use Zod schemas for runtime validation or TypeScript interfaces for compile-time checking.

**Why Zod is recommended for API boundaries**: Runtime validation, automatic type inference, schema-based parsing, environment variable validation, and comprehensive error messages.

**Note on null vs undefined**: For database/API models, use `| null` for nullable fields rather than optional properties (`?`). Database `NULL` and API `null` map to TypeScript `null`, not `undefined`. See `@testing-standards.md` for test data guidance.

```typescript
import { z } from 'zod';

// ✅ CORRECT: Database/API model with explicit null types
interface FileRow {
  DOC_ID: string;
  PARENT: string | null;     // Database NULL maps to null
  COLLECTION: string | null; // API null maps to null
}

// ✅ CORRECT: Zod for API models with runtime validation
const DocumentResponseSchema = z.object({
  documentId: z.string(),
  status: z.string(),
  result: z.record(z.unknown()).nullable(), // API can return null
});

type DocumentResponse = z.infer<typeof DocumentResponseSchema>;

// ✅ CORRECT: Parse JSON from API with validation
const response = DocumentResponseSchema.parse(JSON.parse(jsonString));

// ✅ CORRECT: Zod for configuration with environment variables
const AppConfigSchema = z.object({
  llmApiKey: z.string(),
  llmModel: z.string().default('gpt-4'),
  maxRetries: z.number().int().default(3),
});

type AppConfig = z.infer<typeof AppConfigSchema>;

const config = AppConfigSchema.parse({
  llmApiKey: process.env.LLM_API_KEY,
  llmModel: process.env.LLM_MODEL,
  maxRetries: Number(process.env.MAX_RETRIES),
});

// ❌ WRONG: Plain object - no validation, typos undetected
const requestData = { documentId: "123", conent: "text" };  // Typo undetected!
```

**When to use Zod:**
- ✅ **ALWAYS** for API request/response models
- ✅ **ALWAYS** for parsing external data (APIs, files, user input)
- ✅ **ALWAYS** for configuration with environment variables
- ✅ For complex domain models requiring runtime validation

**When to use TypeScript interfaces/types instead:**
- Internal data structures with compile-time checking only
- Simple data transfer objects within the application
- Type definitions that don't need runtime validation
- Performance-critical code where validation overhead matters

**Key Zod features to use:**
- `.parse()`: Parse and validate data (throws on error)
- `.safeParse()`: Parse and validate, returns result object
- `z.infer<typeof Schema>`: Extract TypeScript type from schema
- `.default()`: Provide default values
- Custom refinements for complex validation

### Type Annotations (MANDATORY)

**RULE**: EVERY function and method parameter MUST have a type annotation. EVERY function and method MUST have a return type annotation. NEVER use `any` type. Zero exceptions.

**Why this matters**: Catches errors at compile time, enables IDE autocomplete, makes code self-documenting, enables safe refactoring.

```typescript
// ✅ CORRECT: All parameters and return types annotated
function processDocuments(
  documents: Document[],
  context: ProcessingContext,
  timeout: number = 30
): ProcessingResult {
  // Implementation
}

// ✅ CORRECT: Async functions with proper typing
async function processDocumentsAsync(
  documents: Document[],
  context: ProcessingContext
): Promise<ProcessingResult> {
  // Implementation
}

// ✅ CORRECT: Test functions with type annotations
describe('processDocuments', () => {
  it('should process documents correctly', (): void => {
    const sampleDocuments: Document[] = createSampleDocuments();
    const result: ProcessingResult = processDocuments(sampleDocuments, mockContext);
    expect(result.success).toBe(true);
  });
});

// ❌ WRONG: Missing type annotations
function processDocuments(documents, context, timeout = 30) {  // Missing all types
  // Implementation
}

// ❌ WRONG: Using 'any' type
function processDocuments(documents: any, context: any): any {  // NEVER use 'any'
  // Implementation
}

// ❌ WRONG: Partial type annotations
function processDocuments(documents: Document[], context, timeout = 30) {  // Missing context type
  // Implementation
}
```

**Applies to:**
- ✅ All production code functions/methods
- ✅ All test functions
- ✅ Arrow functions
- ✅ Return types (use `: void` for procedures)
- ✅ Use `unknown` instead of `any` when type is truly unknown

### Use Interfaces/Types, Not Plain Objects

**RULE**: For structured data (error contexts, configuration, structured logs), use typed interfaces or types instead of plain objects.

**Why this matters**: Plain object keys are strings - typos cause runtime failures. TypeScript interfaces are validated at compile time. IDE autocomplete works. Refactoring is safe.

```typescript
// ✅ CORRECT: Strongly-typed interface
interface LlmErrorContext {
  llmProvider: string;
  llmModel: string;
  httpStatusCode?: number;
}

function createErrorContext(
  provider: string,
  model: string,
  status?: number
): LlmErrorContext {
  return { llmProvider: provider, llmModel: model, httpStatusCode: status };
}

const context: LlmErrorContext = createErrorContext('openai', 'gpt-4');

// ❌ AVOID: Plain object with inline type (typos cause compile errors, but less maintainable)
const context = { 
  llmProvider: "openai", 
  llmModle: "gpt-4"  // Typo undetected if not using interface!
};
```

**Use for**: Error contexts, configuration objects, structured log data, API models
**Prefer interfaces over types for**: Object shapes (better error messages, can be extended)
**Prefer types for**: Unions, intersections, mapped types, utility types

## Magic Number/String Prevention

### Production Code: No Magic Numbers or Strings

**RULES**:
- ✅ **ALWAYS give names to numeric/string literals**: Create constants with descriptive names
- ❌ **NEVER use bare numbers or strings** like `0.09`, `"extraction"`, `1e-10` directly in production code
- ❌ **NEVER use bare empty strings `''` or whitespace strings `' '`** — these are magic values too. Name them: `const CHAR_SEPARATOR = ''`, `const WORD_SEPARATOR = ' '`.
- ✅ **Calculate derived values** when there's a logical relationship (`FINAL_RETRY = MAX_RETRIES - 1`)
- ✅ **Use dynamic calculations** from data when appropriate (`array.length`)
- ❌ **DON'T create constants for test-specific values** like `DOCUMENT_COUNT_3`
- ❌ **DON'T create constants from arbitrary math** like `SECOND_VALUE = FIRST_VALUE + 1` when there's no logical connection

**NOTE**: Test code has different rules - see `@testing-standards.md`

### Production Code Standards

```typescript
// ✅ CORRECT: Named constants — including empty and whitespace strings
const MIN_PROGRESS_VALUE = 0.0;
const MAX_PROGRESS_VALUE = 1.0;
const EXTRACTION_WEIGHT = 0.09;
const EXTRACTION_STEP_TYPE = "extraction";
const CHAR_SEPARATOR = '';      // ✅ empty string as a named constant
const WORD_SEPARATOR = ' ';    // ✅ whitespace string as a named constant

if (value < MIN_PROGRESS_VALUE || value > MAX_PROGRESS_VALUE) {
  throw new Error(
    `Value must be between ${MIN_PROGRESS_VALUE} and ${MAX_PROGRESS_VALUE}`
  );
}

// ❌ AVOID: Magic numbers and magic strings — including empty strings
if (value < 0.0 || value > 1.0) {
  throw new Error("Value must be between 0.0 and 1.0");
}
return value.split('').reverse().join('');   // ❌ '' is a magic string
```

### Constants Organization

```typescript
// Production constants with descriptive names
const MIN_PROGRESS_VALUE = 0.0;
const MAX_PROGRESS_VALUE = 1.0;
const FLOAT_PRECISION_TOLERANCE = 1e-10;
const EXTRACTION_STEP_TYPE = "extraction";
const EXTRACTION_WEIGHT = 0.09;

// Calculated constants for meaningful relationships
const DEFAULT_TIMEOUT_SECONDS = 5;
const EXTENDED_TIMEOUT_SECONDS = DEFAULT_TIMEOUT_SECONDS * 3;  // Extended is 3x default
const MAX_RETRY_ATTEMPTS = 3;
const FINAL_RETRY_ATTEMPT = MAX_RETRY_ATTEMPTS - 1;  // Final attempt is last index
```

## Import Organization

### Import Organization (Standard ES6)

**RULES**:
- ✅ **ALL imports at the top**: First thing after file comments, before any other code
- ✅ **Group imports in order**: (1) External libraries, (2) Internal modules, (3) Types
- ✅ **One import per line** for clarity (or use multi-line for multiple items)
- ❌ **NEVER import inside functions**: No imports inside functions, methods, or conditionals
- ❌ **No conditional imports**: Exception: dynamic imports for code splitting

### Import Organization Example

```typescript
// ✅ CORRECT: All imports at top, properly organized
/**
 * Document processing pipeline module.
 */

// External library imports
import { z } from 'zod';
import structlog from 'structlog';

// Internal module imports
import { Document } from '@/common/models';
import { DocumentObligationExtraction } from '@/oes-skill/models';

// Type imports (can be separate or inline with 'type' keyword)
import type { ProcessingContext, ProcessingResult } from '@/types';

// Initialize logger once at module level
const logger = structlog.getLogger();

class Pipeline {
  async process(): Promise<void> {
    try {
      // Use logger directly - no inline imports
      logger.info('Processing started');
      // ... processing logic ...
    } catch (error) {
      logger.error('Error occurred', { error });
      throw error;
    }
  }
}
```

### Common Import Anti-Patterns

```typescript
// ❌ AVOID: Inline imports
function processData(): void {
  const structlog = require('structlog');  // Should be at top of file
  const logger = structlog.getLogger();    // Should be module-level
}

// ❌ AVOID: Imports in exception handlers
try {
  // ... code ...
} catch (error) {
  const structlog = require('structlog');  // Should be at top of file
  const logger = structlog.getLogger();
  logger.error('Error occurred', { error });
}

// ✅ CORRECT: Module-level imports and logger
import structlog from 'structlog';
const logger = structlog.getLogger();

function processData(): void {
  try {
    // ... code ...
  } catch (error) {
    logger.error('Error occurred', { error });
    throw error;
  }
}

// ✅ CORRECT: Dynamic imports for code splitting (acceptable exception)
async function loadHeavyModule(): Promise<void> {
  const { heavyFunction } = await import('./heavy-module');
  heavyFunction();
}
```

## Implementation Guidelines

### Your Development Workflow

**FOLLOW THIS ORDER**:
1. **Plan**: Design the component architecture and interfaces
2. **RED**: Write a failing test that defines the expected behavior
3. **GREEN**: Write minimal code to make the test pass
4. **REFACTOR**: Clean up code while keeping all tests passing
5. **Document**: Add JSDoc comments and explanatory comments
6. **Verify**: Check that you followed TDD and all coding standards

### Code Review Criteria
1. **Functionality**: Works correctly, handles edge cases
2. **Standards**: Follows all guidelines in this document
3. **Magic Values**: Zero hardcoded numbers/strings
4. **Type Safety**: Proper type annotations and no `any` types
5. **SOLID Principles**: Clean design patterns
6. **Documentation**: Clear JSDoc comments

### Quality Gates
- All tests must pass
- >95% code coverage for new code
- TypeScript compiler passes with strict mode
- Zero magic numbers/strings in production code, controlled usage in test code
