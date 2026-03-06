# Testing Standards

**INSTRUCTION FOR AI ASSISTANT**: These are MANDATORY rules for writing quality tests. Follow these when writing ANY test code.

## Import Organization (MANDATORY)

**RULE**: Use absolute imports for production code, relative imports for test utilities.

```python
# ✅ CORRECT
from skills_sdk.flow_storage import InMemoryStorage  # Production - absolute
from .common_flows import InputModel  # Test utility - relative

# ❌ WRONG
from tests.unit.common_flows import InputModel  # Should be relative
from ...skills_sdk.flow_storage import InMemoryStorage  # Should be absolute
```

## Unit Test Scope (MANDATORY)

**RULE**: Unit tests MUST test only ONE module. All other modules MUST be mocked.

```python
# ✅ CORRECT: All dependencies mocked
class TestDocumentProcessor:
    @pytest.mark.asyncio
    async def test_process_document(self) -> None:
        # Arrange
        mock_llm = AsyncMock()
        mock_storage = AsyncMock()
        processor = DocumentProcessor(mock_llm, mock_storage)
        # Act
        result = await processor.process("test.pdf")
        # Assert
        assert result.success

# ❌ WRONG: Real dependencies (integration test)
llm_client = RealLLMClient()  # Not mocked!
processor = DocumentProcessor(llm_client, storage)
```

**Mock**: API clients, databases, file systems, other modules, time functions  
**Don't mock**: Standard library types, module under test, simple data models

## Async Testing (MANDATORY)

**RULE**: Use `@pytest.mark.asyncio` and `async def` for async tests.

```python
# ✅ CORRECT
@pytest.mark.asyncio
async def test_async_processing() -> None:
    mock_client = AsyncMock()
    result = await process_async(mock_client, "test.pdf")
    assert result.success

# ❌ WRONG: Missing async
def test_async_processing() -> None:
    result = process_async(mock_client)  # Missing await!
```

**Requirements**: Use `@pytest.mark.asyncio`, `async def`, `await`, `AsyncMock` (not `Mock`)

## Fixture Usage (MANDATORY)

**RULE**: Extract repeated setup code into fixtures immediately.

```python
# ✅ CORRECT: Fixture eliminates duplication
@pytest.fixture
def sample_documents() -> list[Document]:
    return [create_document(f"doc_{i}") for i in range(3)]

def test_single(sample_documents: list[Document]) -> None:
    result = process(sample_documents[0])
    assert result.success

def test_batch(sample_documents: list[Document]) -> None:
    results = process_batch(sample_documents)
    assert len(results) == 3

# ❌ WRONG: Duplicated setup
def test_single() -> None:
    sample_documents = [create_document(f"doc_{i}") for i in range(3)]  # Duplicated
    result = process(sample_documents[0])

def test_batch() -> None:
    sample_documents = [create_document(f"doc_{i}") for i in range(3)]  # Duplicated
```

## Test Structure: AAA (MANDATORY)

**RULE**: Use exact comments: `# Arrange`, `# Act`, `# Assert` (no extra text).

```python
# ✅ CORRECT
def test_functionality(self) -> None:
    # Arrange
    expected_progress = 0.5
    mock_update = AsyncMock()
    # Act
    context = ProcessingContext(mock_update, 3)
    await context.complete_step("extraction")
    # Assert
    assert abs(mock_update.call_args[0][0] - expected_progress) < FLOAT_PRECISION_TOLERANCE

# ❌ WRONG: Verbose comments
# Arrange: Set up test data  # Too verbose
```

## Test Parameterization

**RULE**: Use `@pytest.mark.parametrize` when same Act/Assert logic, different Arrange data.

```python
# ✅ CORRECT: Parameterized
@pytest.mark.parametrize("status,expected", [
    (FlowStatus.INITIALIZED, "initial"),
    (FlowStatus.RESUMING, "resumed"),
], ids=["initialized", "resuming"])
def test_flow_behavior(status, expected):
    # Single test covers multiple scenarios

# ❌ WRONG: Duplicate methods
def test_initialized_flow(): ...  # 30 lines
def test_resuming_flow(): ...     # 30 nearly identical lines
```

**When to parameterize**: Same logic, different inputs | Boundary conditions  
**When NOT to**: Different test logic | Single scenario

## Test Constants

**Use LOCAL constants**: Expected/assertion values in ONE test only  
**Use DIRECT literals**: In `@pytest.mark.parametrize`, mock-only values, simple setup  
**Use GLOBAL constants**: Value asserted in 2+ tests, shared fixture values, test infrastructure

```python
# ✅ Local - test-specific assertion value
def test_retry(self):
    expected_max_retries = 6  # Local - used only here
    client = create_client(max_retries=expected_max_retries)
    assert client.max_retries == expected_max_retries

# ✅ Direct literals - parametrize
@pytest.mark.parametrize("count", [1, 5, 10])  # Direct literals
def test_retries(self, count): ...

# ✅ Global - asserted in multiple tests
SAMPLE_DOCUMENT_COUNT = 3  # Used in fixture and asserted in multiple tests
FLOAT_PRECISION_TOLERANCE = 1e-10  # Used across many tests

@pytest.fixture
def sample_documents():
    return [create_document(f"doc_{i}") for i in range(SAMPLE_DOCUMENT_COUNT)]

def test_processing(sample_documents):
    result = process(sample_documents)
    assert len(result.documents) == SAMPLE_DOCUMENT_COUNT  # Global
```

**Decision tree**:
1. In `@pytest.mark.parametrize`? → Direct literal
2. Only for creating mocks? → Direct literal
3. In assertion, ONE test? → Local constant
4. In assertion, MULTIPLE tests? → Global constant

**Avoid**:
- ❌ Global for single-test values
- ❌ Math with globals (`GLOBAL + 1`)
- ❌ Globals just for parametrize
- ❌ Globals for coincidentally identical values testing different things

**Atomic replacement**: When creating a constant, replace ALL occurrences or don't create it.

## Mocking Best Practices

**RULE**: Use `patch.object` for mocking methods and attributes. NEVER use direct assignment.

```python
# ✅ CORRECT: Use patch.object for methods
with patch.object(pipeline.document_downloader, 'download_document', 
                  new_callable=AsyncMock, return_value=sample_doc) as mock_download:
    result = await pipeline.process()
    mock_download.assert_called_once()

# ✅ CORRECT: Use patch.object as decorator
@patch.object(DocumentDownloader, 'download_document', new_callable=AsyncMock)
async def test_process(mock_download):
    mock_download.return_value = sample_doc
    result = await pipeline.process()

# ✅ CORRECT: Patch multiple methods
with patch.object(downloader, 'download_document', new_callable=AsyncMock) as mock_dl, \
     patch.object(downloader, 'cleanup_document', new_callable=Mock) as mock_cleanup:
    await pipeline.process()
    mock_cleanup.assert_called_once()

# ❌ WRONG: Direct assignment (causes mypy errors)
pipeline.document_downloader.download_document = AsyncMock()  # mypy error!
pipeline.document_downloader.cleanup_document = Mock()  # mypy error!
```

## Derive Expected Values from Mocked Data (MANDATORY)

**RULE**: Every value in an assertion that originates from a mock, fixture, or test
constant **MUST** be referenced from that source — never re-typed as a literal.
This applies to **all** mock-originated values: object fields, computed strings,
IDs, timestamps, emails, numbers, config values, etc.

**Field mapping — assert via mock object:**
```python
mock_row = {
    "ID": "collection-001",
    "USER_ID": "user@example.com",
    "ORG_ID": DEFAULT_ORG_ID,
    "CREATED_AT": "2026-01-01T10:00:00Z",
}
mock_client.fetch_rows.return_value = [mock_row]

# ❌ WRONG: Re-hardcoded strings from mock_row
assert logs[0].id == "collection-001"
assert logs[0].user_id == "user@example.com"
assert logs[0].created_at == "2026-01-01T10:00:00Z"

# ✅ CORRECT: Derived from mock_row
assert logs[0].id == mock_row["ID"]
assert logs[0].user_id == mock_row["USER_ID"]
assert logs[0].created_at == mock_row["CREATED_AT"]
```

**Computed strings — derive from config:**
```python
mock_config = {"DATABASE": "DB", "SCHEMA": "SCH"}
FOLDERS_VIEW = "FOLDERS_VW"

# ❌ WRONG: Hardcoded duplicate of mock values
assert "DB.SCH.FOLDERS_VW" in call_args.sql_text

# ✅ CORRECT: Fully derived from mock
expected_table = f"{mock_config['DATABASE']}.{mock_config['SCHEMA']}.{FOLDERS_VIEW}"
assert expected_table in call_args.sql_text
```

**Why**: If the mock value changes, the assertion breaks immediately — catching
the mismatch at edit time instead of producing a false-green test.

## Test Quality Checklist

**MANDATORY**:
- [ ] Absolute imports for production, relative for test utilities
- [ ] All parameters have type annotations
- [ ] New code has >95% test coverage
- [ ] Fixtures used for all common setup (no duplication)
- [ ] AAA structure with clean comments: `# Arrange`, `# Act`, `# Assert`
- [ ] Unit tests mock all dependencies except module under test
- [ ] Async tests use `@pytest.mark.asyncio` and `AsyncMock`
- [ ] Same Act+Assert logic uses `@pytest.mark.parametrize`
- [ ] Expected values derived from mocks, not re-hardcoded
- [ ] Local constants for single-test assertions
- [ ] Global constants ONLY for multi-test assertions
- [ ] Direct literals in parametrize and mock-only values
- [ ] Zero unnecessary global constants
- [ ] Proper mocking with `patch.object`
