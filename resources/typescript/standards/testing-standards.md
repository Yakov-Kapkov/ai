# Testing Standards

**INSTRUCTION FOR AI ASSISTANT**: These are MANDATORY rules for writing quality tests. Follow these when writing ANY test code.

## Table of Contents

- [Import Organization](#import-organization)
- [Unit Test Scope](#unit-test-scope)
- [Async Testing](#async-testing)
- [Test Setup and Utilities](#test-setup-and-utilities)
- [Test Structure (AAA)](#test-structure-aaa)
- [Test Parameterization](#test-parameterization)
- [Test Constants](#test-constants)
- [Mocking Best Practices](#mocking-best-practices)
- [Test Quality Checklist](#test-quality-checklist)

## Import Organization

### Import Organization in Test Files (MANDATORY)

**RULE**: When writing test files, use absolute imports for production code being tested and relative imports for test utilities.

```typescript
// ✅ CORRECT: Proper import organization
import { describe, it, expect, beforeEach, vi } from 'vitest';  // or 'jest'

// Production code - absolute imports
import { FlowStorage } from '@/flow-storage/flow-storage';
import { InMemoryStorage } from '@/flow-storage/in-memory-storage';

// Test utilities - relative imports
import { createTestFlow, InputModel } from './common-flows';
import { JWT_PRIVATE_KEY } from './test-config';

// ❌ WRONG: Absolute imports for test utilities
import { createTestFlow } from '@/tests/unit/common-flows';  // Should be: from './common-flows'

// ❌ WRONG: Relative imports for production code
import { FlowStorage } from '../../../src/flow-storage';  // Should be: from '@/flow-storage'
```

## Unit Test Scope

### Unit Test Scope (MANDATORY)

**RULE**: Unit tests MUST test only ONE module. All other modules MUST be mocked.

**Why this matters**: Unit tests verify individual components in isolation. Testing multiple modules creates integration tests, which are slower, harder to debug, and harder to maintain.

```typescript
// ✅ CORRECT: Unit test with all dependencies mocked
import { describe, it, expect, vi } from 'vitest';
import { DocumentProcessor } from '@/modules/document-processor';  // The ONE module being tested

describe('DocumentProcessor', () => {
  it('should process document in isolation', async (): Promise<void> => {
    // Arrange
    const mockLlmClient = {
      analyze: vi.fn().mockResolvedValue({ result: 'success' }),
    };
    const mockStorage = {
      save: vi.fn().mockResolvedValue(undefined),
    };
    const processor = new DocumentProcessor(mockLlmClient, mockStorage);
    
    // Act
    const result = await processor.process('test.pdf');
    
    // Assert
    expect(result.success).toBe(true);
    expect(mockLlmClient.analyze).toHaveBeenCalledOnce();
  });
});
```

**What to mock in unit tests:**
- ✅ External API clients (LLM, Document Understanding, etc.)
- ✅ Database connections and ORM instances
- ✅ File system operations
- ✅ Other modules from your codebase
- ✅ Time/date functions (for deterministic tests)

**What NOT to mock:**
- ✅ Standard library data structures (Array, Map, Set)
- ✅ The specific module you're testing
- ✅ Simple value objects and interfaces

## Async Testing

### Async Testing (MANDATORY)

**RULE**: When testing asynchronous functions, you MUST use `async`/`await` in test functions and ensure proper return type annotation.

**Why this matters**: Async functions must be awaited. Tests that don't await async operations will pass incorrectly and hide bugs.

```typescript
// ✅ CORRECT: Async test for async function
import { describe, it, expect, vi } from 'vitest';

describe('DocumentProcessor', () => {
  it('should process document asynchronously', async (): Promise<void> => {
    // Arrange
    const mockClient = {
      process: vi.fn().mockResolvedValue({ status: 'success' }),
    };
    
    // Act
    const result = await processDocumentAsync(mockClient, 'test.pdf');
    
    // Assert
    expect(result.status).toBe('success');
    expect(mockClient.process).toHaveBeenCalledWith('test.pdf');
  });
});

```

**Key requirements:**
- `async` with return type `Promise<void>` on test functions and async setup/teardown
- `await` every async call — un-awaited calls cause false passes
- Use `mockResolvedValue()` / `mockRejectedValue()` for async mocks

## Test Setup and Utilities

### Test Data Creation: Database/API Simulation (MANDATORY)

**RULE**: When creating test data that simulates database rows or API responses, use `null` for nullable fields, NOT `undefined`.

**Why this matters**: Database `NULL` values serialize to JSON `null`, not `undefined`. Using `undefined` in test data creates unrealistic scenarios that don't match actual runtime behavior.

```typescript
// ✅ CORRECT: Test data simulating database/API response
const mockDatabaseRow: FileRow = {
  DOC_ID: 'doc-001',
  PARENT: null,           // Database NULL maps to null
};

// ✅ CORRECT: Test data for API response
const mockApiResponse = {
  documentId: 'doc-001',
  result: null,           // API returns null for missing values
};

// ❌ WRONG: Using undefined for database/API simulation
const unrealisticRow: FileRow = {
  DOC_ID: 'doc-001',
  PARENT: undefined,      // Databases, APIs don't return undefined
};
```

**When to use `null` in test data:**
- ✅ Simulating database rows with nullable columns
- ✅ Mocking API responses with optional fields
- ✅ Testing data transformation from external sources
- ✅ Any test data representing serialized JSON

**When `undefined` is acceptable:**
- ✅ Optional parameters in function calls: `processData(doc, undefined)`
- ✅ Missing object properties in pure TypeScript objects
- ✅ Test configuration where a field truly isn't provided

### Test Setup and Utilities (MANDATORY)

**RULE**: If you're repeating the same setup code in multiple tests, extract it into a helper function or use `beforeEach` immediately.

**Use setup utilities when you see:**
- Same test data created in 2+ test cases
- Same object initialization repeated across tests
- Same mock configuration duplicated
- Same database/service setup repeated

```typescript
// ✅ CORRECT: Using setup utilities and beforeEach
function createSampleDocuments(count: number = 3): Document[] {
  return Array.from({ length: count }, (_, i) => createDocument(`doc_${i}`));
}

function createMockLlmClient(): MockLlmClient {
  return {
    generate: vi.fn().mockResolvedValue('test response'),
    analyze: vi.fn(),
  };
}

describe('DocumentProcessing', () => {
  let sampleDocuments: Document[];
  let mockClient: MockLlmClient;

  beforeEach((): void => {
    sampleDocuments = createSampleDocuments();
    mockClient = createMockLlmClient();
  });

  it('should process single document', (): void => {
    // Arrange
    const processor = new DocumentProcessor(mockClient);
    
    // Act
    const result = processor.process(sampleDocuments[0]);
    
    // Assert
    expect(result.success).toBe(true);
  });

  it('should process batch of documents', (): void => {
    // Arrange
    const processor = new DocumentProcessor(mockClient);
    
    // Act
    const results = processor.processBatch(sampleDocuments);
    
    // Assert
    expect(results).toHaveLength(3);
  });
});

```

## Test Structure (AAA)

### Test Structure: Arrange-Act-Assert

**RULE**: Every test MUST have three sections marked with exact comments: `// Arrange`, `// Act`, `// Assert`

**Format**: Use ONLY these exact comments - no extra text:
- `// Arrange` (not `// Arrange: setup test data`)
- `// Act` (not `// Act: call the function`)
- `// Assert` (not `// Assert: verify results`)

**Why**: Consistency, readability, clear test structure.

```typescript
// ✅ CORRECT: Clean AAA comments
it('should complete step and update progress', async (): Promise<void> => {
  // Arrange
  const documentCount = 3;  // Local test setup value
  const expectedProgress = 0.5;  // Local constant for assertion
  const mockUpdate = vi.fn();

  // Act
  const context = new ProcessingContext(mockUpdate, documentCount);
  await context.completeStep('extraction');

  // Assert
  expect(mockUpdate).toHaveBeenCalledOnce();
  const actualProgress = mockUpdate.mock.calls[0][0];
  expect(Math.abs(actualProgress - expectedProgress)).toBeLessThan(FLOAT_PRECISION_TOLERANCE);
});
```

## Test Parameterization

### Test Parameterization: Eliminate Duplicate Test Logic

**RULE**: When multiple tests have the same Act and Assert sections but different Arrange data, use `it.each` or `describe.each` instead of separate test cases.

```typescript
// ✅ CORRECT: Parameterized test reduces duplication
describe('flow behavior', () => {
  it.each([
    { status: FlowStatus.INITIALIZED, expectedFlag: false, expectedResult: 'initial_result' },
    { status: FlowStatus.RESUMING, expectedFlag: true, expectedResult: 'resumed_result' },
  ])('should handle $status status correctly', ({ status, expectedFlag, expectedResult }): void => {
    // Arrange
    const flow = createFlow(status);
    
    // Act
    const result = flow.process();
    
    // Assert
    expect(result.flag).toBe(expectedFlag);
    expect(result.value).toBe(expectedResult);
  });
});

```

Use `it.each` when the same Act+Assert logic applies to different inputs. Use separate tests when the code paths differ.

**Before writing any test, ask:** "Does another test already call this same production code with just different data?" If yes → parameterize; if no → separate test.

**Red flags for duplication:** similar test names with minor variations, same Act/Assert with only Arrange differing, multiple tests calling same function with different inputs.

## Test Constants

### Test Constants: When to Name Values

**Use LOCAL constants (most common):**
1. **Expected values in assertions**: Values you assert against, used in ONE test only
2. **Test configuration**: Setup values specific to ONE test
3. **Calculated expectations**: Values derived from the specific test's context

**Use DIRECT LITERALS (no constant needed):**
1. **In `it.each` arrays**: Just write `[1, 5, 7, 10]` directly
2. **For mock creation only**: Values used to create mocks but never asserted
3. **Simple setup assignments**: Values that configure the test but aren't verified (`documentCount = 3`)

**Use MODULE-LEVEL constants (rare - only when truly shared):**
1. **Setup values asserted in multiple tests**: Value created in setup AND asserted in 2+ tests
2. **Same assertion value across tests**: Identical expected value asserted in multiple unrelated tests
3. **Test infrastructure values**: Technical constants used across many tests
   - ✅ Example: `FLOAT_PRECISION_TOLERANCE = 1e-10` (used in float comparisons across many tests)
   - ✅ Example: `DEFAULT_TEST_TIMEOUT = 30` (timeout used across many tests)
   - ✅ Example: `TEST_ACCESS_TOKEN = 'mock-token-123'` (same token asserted in multiple tests)

### Examples

```typescript
// ✅ Local Constants - Test-specific expected values
it('should configure retry settings correctly', (): void => {
  // Arrange
  const expectedMaxRetries = 6;  // Local - used only in this test
  const expectedTimeout = 30;
  const client = createClient({ maxRetries: expectedMaxRetries, timeout: expectedTimeout });

  // Act & Assert
  expect(client.maxRetries).toBe(expectedMaxRetries);
  expect(client.timeout).toBe(expectedTimeout);
});

// ✅ Direct Literals - Parameterize arrays (no constants needed)
describe.each([
  { retryCount: 1, expectedSuccess: true },
  { retryCount: 5, expectedSuccess: true },
  { retryCount: 10, expectedSuccess: false },
])('retry behavior with $retryCount retries', ({ retryCount, expectedSuccess }): void => {
  it('should handle retries correctly', (): void => {
    // Arrange & Act
    const result = processWithRetries(retryCount);
    // Assert
    expect(result.success).toBe(expectedSuccess);
  });
});

// ✅ Module-Level Constants - Shared across tests
const SAMPLE_DOCUMENT_COUNT = 3;

describe('DocumentProcessing', () => {
  let sampleDocuments: Document[];
  beforeEach((): void => {
    sampleDocuments = Array.from({ length: SAMPLE_DOCUMENT_COUNT }, (_, i) =>
      createDocument(`doc_${i}`)
    );
  });

  it('should process all documents', (): void => {
    // Arrange
    const expectedStatus = 'completed';  // Local
    // Act
    const result = processDocuments(sampleDocuments);
    // Assert
    expect(result.documents).toHaveLength(SAMPLE_DOCUMENT_COUNT);  // Module-level
    expect(result.status).toBe(expectedStatus);  // Local
  });
});
```

### Decision Tree for Test Values

**Step 1: Where is the value?**
- In `it.each([...])` or `describe.each([...])` → Use **direct literal**
- Only for creating mocks → Use **direct literal**
- In an assertion → Go to Step 2

**Step 2: How many tests assert this EXACT value?**
- ONE test only → Use **local constant** in that test
- MULTIPLE tests assert the same value → Use **module-level constant**

**Step 3: Avoid these mistakes:**
- ❌ Don't make module-level constants for single-test values
- ❌ Don't do math with constants (`CONSTANT + 1`)
- ❌ Don't make constants just for `it.each` arrays
- ❌ Don't make constants for coincidentally identical values

### Derive Expected Values from Mocked Data (MANDATORY)

**RULE**: Every value in an assertion that originates from a mock, fixture, or test
constant **MUST** be referenced from that source — never re-typed as a literal.
This applies to **all** mock-originated values: object fields, computed strings,
IDs, timestamps, emails, numbers, config values, etc.

**Field mapping — assert via mock object:**
```typescript
const mockRow = {
  ID: 'collection-001',
  USER_ID: 'user@example.com',
  ORG_ID: DEFAULT_ORG_ID,
  CREATED_AT: '2026-01-01T10:00:00Z',
};
mockClient.fetchRows.resolves([mockRow]);

// ❌ WRONG: Re-hardcoded strings from mockRow
expect(logs[0].id).to.equal('collection-001');
expect(logs[0].userId).to.equal('user@example.com');
expect(logs[0].createdAt).to.equal('2026-01-01T10:00:00Z');

// ✅ CORRECT: Derived from mockRow
expect(logs[0].id).to.equal(mockRow.ID);
expect(logs[0].userId).to.equal(mockRow.USER_ID);
expect(logs[0].createdAt).to.equal(mockRow.CREATED_AT);
```

**Computed strings — derive from config:**
```typescript
const mockConfig = { DATABASE: 'DB', SCHEMA: 'SCH' };
const FOLDERS_VIEW = 'FOLDERS_VW';

// ❌ WRONG: Hardcoded duplicate of mock values
expect(callArgs.sqlText).to.include('DB.SCH.FOLDERS_VW');

// ✅ CORRECT: Fully derived from mock
const expectedTable = `${mockConfig.DATABASE}.${mockConfig.SCHEMA}.${FOLDERS_VIEW}`;
expect(callArgs.sqlText).to.include(expectedTable);
```

**Why**: If the mock value changes, the assertion breaks immediately — catching
the mismatch at edit time instead of producing a false-green test.

## Mocking Best Practices

### Mocking Best Practices

```typescript
// ✅ CORRECT: Using vi.spyOn for method mocking
import { vi } from 'vitest';

it('should call internal method', async (): Promise<void> => {
  // Arrange
  const context = new ProcessingContext();
  const spy = vi.spyOn(context, 'completeStep').mockResolvedValue(undefined);
  
  // Act
  await context.process();
  
  // Assert
  expect(spy).toHaveBeenCalledWith('extraction');
  spy.mockRestore();
});

// ✅ CORRECT: Mock entire module
vi.mock('@/services/llm-client', () => ({
  LlmClient: vi.fn().mockImplementation(() => ({
    analyze: vi.fn().mockResolvedValue({ result: 'success' }),
  })),
}));

// ❌ AVOID: Direct method assignment (TypeScript errors)
const context = new ProcessingContext();
context.completeStep = vi.fn();  // Type error
```

## Test Quality Checklist

### Test Quality Checklist
- [ ] **Import organization: absolute for production code, relative for test utilities**
- [ ] **All parameters have type annotations including `: void` or `: Promise<void>`; never use `any`**
- [ ] **Setup utilities used for all common test setup (no duplication)**
- [ ] **AAA structure with exact comments: `// Arrange`, `// Act`, `// Assert`**
- [ ] **Semantic duplication check: same Act+Assert with different data → `it.each`/`describe.each`**
- [ ] **Expected values derived from mocks, not re-hardcoded**
- [ ] Named constants for assertion values (local if single-test, module-level if cross-test)
- [ ] Direct literals for mock setup, `it.each` arrays, and non-asserted config
- [ ] No module-level constants for single-test values, `it.each` arrays, or arithmetic
- [ ] Proper mocking with `vi.spyOn` or `vi.mock`
