# Coding Standards

**INSTRUCTION FOR AI ASSISTANT**: These are MANDATORY technical rules for writing production Python code. Every rule marked MANDATORY is non-negotiable.

## Table of Contents

- [Core Principles](#core-principles)
- [Type Safety and Strongly-Typed Patterns](#type-safety-and-strongly-typed-patterns)
- [Magic Number/String Prevention](#magic-numberstring-prevention)
- [Import Organization](#import-organization)
- [Comments and Documentation](#comments-and-documentation)

## Core Principles

### SOLID Design Principles
- **Single Responsibility**: Each class/method has one clear purpose
- **Open/Closed**: Extensible without modification
- **Liskov Substitution**: Derived classes are substitutable for base classes
- **Interface Segregation**: Clean, focused interfaces
- **Dependency Inversion**: Depend on abstractions, not implementations

## Type Safety and Strongly-Typed Patterns

### Data Models: Use Pydantic (MANDATORY)

**RULE**: Use Pydantic BaseModel for ALL data models, API models, and configuration objects.

**Why**: Runtime validation, type conversion, JSON serialization, environment parsing, IDE autocomplete.

```python
from pydantic import BaseModel, Field, field_validator
from pydantic_settings import BaseSettings

# ✅ CORRECT: Pydantic for API models
class DocumentRequest(BaseModel):
    document_id: str = Field(..., description="Unique identifier")
    content: str = Field(..., min_length=1)
    
    @field_validator('document_id')
    @classmethod
    def validate_id(cls, v: str) -> str:
        return v.strip()

# ✅ CORRECT: Parse LLM JSON with validation
response = DocumentResponse.model_validate_json(json_string)

# ✅ CORRECT: Settings with env variables
class AppSettings(BaseSettings):
    llm_api_key: str
    llm_model: str = "gpt-4"
    model_config = {"env_file": ".env"}

# ❌ WRONG: Plain dict - no validation
request_data = {"document_id": "123", "conent": "text"}  # Typo undetected!
```

**Use Pydantic for**: API request/response, configuration (`BaseSettings`), LLM JSON parsing, domain models  
**Use dataclasses for**: Simple internal structures, error contexts, performance-critical paths

**Key features**: `model_validate_json()`, `model_dump()`, `Field(...)`, `@field_validator`, `BaseSettings`

### Type Annotations (MANDATORY)

**RULE**: ALL parameters and return types MUST have type annotations. Zero exceptions.

```python
# ✅ CORRECT
def process_documents(documents: list[Document], timeout: int = 30) -> ProcessingResult:
    pass

@pytest.mark.asyncio
async def test_process(sample_docs: list[Document]) -> None:
    pass

# ❌ WRONG: Missing annotations
def process_documents(documents, timeout=30):  # Missing all type hints
    pass
```

**Applies to**: Production code, test functions, fixtures, lambdas (where possible). Use `-> None` for procedures.

### Use Dataclasses, Not Dictionaries (MANDATORY)

**RULE**: Use typed dataclasses for structured data (error contexts, configs, structured logs).

**Why**: Dictionary typos cause runtime failures. Dataclasses validated by mypy at dev time. IDE autocomplete works.

```python
from dataclasses import dataclass, asdict

# ✅ CORRECT
@dataclass
class LlmErrorContext:
    llm_provider: str
    llm_model: str
    http_status_code: Optional[int] = None
    
    def to_dict(self) -> dict:
        return {k: v for k, v in asdict(self).items() if v is not None}

context = LlmErrorContext(llm_provider="openai", llm_model="gpt-4")

# ❌ WRONG: Dict with string keys
context = {"llm_provider": "openai", "llm_modle": "gpt-4"}  # Typo undetected!
```

**Use for**: Error contexts, configs, structured logs  
**Don't use for**: Simple 2-3 field dicts, dynamic keys, external data (use Pydantic)

## Magic Number/String Prevention (MANDATORY)

**RULES for production code**:
- ✅ **ALWAYS name numeric/string literals**: Create descriptive constants
- ❌ **NEVER use bare numbers/strings** like `0.09`, `"extraction"`, `1e-10`
- ❌ **NEVER use bare empty strings `''` or whitespace strings `' '`** — these are magic values too. Name them: `CHAR_SEPARATOR = ''`, `WORD_SEPARATOR = ' '`.
- ✅ **Calculate derived values** when logical relationship exists

**NOTE**: Test code has different rules - see `@testing-standards.md`. In particular: assertion values that originate from a mock or fixture object **must** be derived from that object (`mock_row["total_count"]`), not re-typed as a literal (`5`).

```python
# ✅ CORRECT: Named constants — including empty and whitespace strings
MIN_PROGRESS_VALUE = 0.0
MAX_PROGRESS_VALUE = 1.0
EXTRACTION_WEIGHT = 0.09
FLOAT_PRECISION_TOLERANCE = 1e-10
CHAR_SEPARATOR = ''      # ✅ empty string as a named constant
WORD_SEPARATOR = ' '     # ✅ whitespace string as a named constant

# Calculated constants for meaningful relationships
DEFAULT_TIMEOUT_SECONDS = 5
EXTENDED_TIMEOUT_SECONDS = DEFAULT_TIMEOUT_SECONDS * 3  # Extended is 3x
MAX_RETRY_ATTEMPTS = 3
FINAL_RETRY_ATTEMPT = MAX_RETRY_ATTEMPTS - 1  # Last index

if not (MIN_PROGRESS_VALUE <= value <= MAX_PROGRESS_VALUE):
    raise ValueError(f"Value must be between {MIN_PROGRESS_VALUE} and {MAX_PROGRESS_VALUE}")

# ❌ WRONG: Magic numbers and magic strings — including empty strings
if not (0.0 <= value <= 1.0):  # What do these values represent?
    raise ValueError("Value must be between 0.0 and 1.0")
return CHAR_SEPARATOR.join(reversed(value))  # ✅ vs ''.join(reversed(value))  ❌
```

## Import Organization (MANDATORY)

**RULES**:
- ✅ **ALL imports at top**: First after module docstring
- ✅ **Group in order**: (1) Standard library, (2) Third-party, (3) Local
- ✅ **One import per line**: Exception - multiple items from same module OK
- ❌ **NO inline imports**: No imports inside functions/methods/except blocks
- ❌ **NO conditional imports**: Exception - optional dependencies or platform-specific

```python
# ✅ CORRECT
"""Module docstring."""

# Standard library
from typing import List
from uuid import UUID

# Third-party
from pydantic import BaseModel
import structlog

# Local
from common.models import Document

logger = structlog.get_logger(__name__)  # Module-level

class Pipeline:
    async def process(self):
        try:
            logger.info("Processing")
        except Exception as e:
            logger.error(f"Error: {e}", exc_info=True)
            raise

# ❌ WRONG: Inline imports
def process_data():
    import json  # Should be at top
    import structlog  # Should be at top
```

## Comments and Documentation

See `@code-style.md`
