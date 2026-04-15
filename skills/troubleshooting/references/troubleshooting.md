# Troubleshooting Dictionary

Symptom → cause → fix. Language-agnostic.

## Index

Read **only this table first**. Match the symptom keyword, then read only the listed lines.

| Section | Keywords | Lines |
|---|---|---|
| Test Failures | env var, import not found, test hangs, false green, RED expected | 19–27 |
| Build / Compile Errors | type error, cannot find name, unresolved reference | 29–34 |
| Lint / Style Errors | import order, unused import, magic number | 36–42 |
| Command Execution | env var not set, KeyError, empty config, dotenv | 44–48 |
| Quality Gate Failures | coverage below threshold, coverage no output | 50–55 |

---

## Test Failures

| Symptom | Cause | Fix |
|---|---|---|
| `KeyError` / `ValidationError` / crash on missing env var during test collection or run | Code reads environment variables but no test fixture provides them | Add a test fixture that sets required env vars before the test runs — never set env vars in the shell command |
| Module not found / cannot resolve import in test file | Wrong import path or missing dependency | Fix import path per project conventions (typically absolute for production code, relative for test utilities) |
| Test hangs indefinitely (no output, no failure) | Real network call — no mock on HTTP/DB/socket dependency | Mock every external endpoint; unit tests must never make real I/O |
| Async test passes but should fail (false green) | Missing await or wrong mock type for async code | Ensure test uses async patterns and async-compatible mocks |
| All tests pass when RED was expected | Assertions test negative conditions that are trivially true before feature exists | Revise assertions to depend on the not-yet-implemented behaviour |

## Build / Compile Errors

| Symptom | Cause | Fix |
|---|---|---|
| Type error after adding a new function parameter | Callers not updated | Update all call sites to pass the new argument |
| "Cannot find name" / "unresolved reference" | Symbol not exported or not imported | Add export at the source, import at the consumer |

## Lint / Style Errors

| Symptom | Cause | Fix |
|---|---|---|
| Import order violation | Imports not grouped per project convention | Reorganize: stdlib → third-party → project → relative |
| Unused import warning | Import left over after refactoring | Remove the import |
| Magic number / string flagged | Literal used instead of named constant | Extract to a named constant |

## Command Execution

| Symptom | Cause | Fix |
|---|---|---|
| Command fails with "env var not set" / `KeyError` / empty-string config error | Required environment variable not configured in the shell session | **During tests:** add a test fixture that sets the var (see Test Failures above). **Outside tests:** check project setup docs for required env vars; verify `.env` / shell profile; if the project uses a dotenv loader, ensure it runs before the failing command. Never prepend `VAR=value` to the command. |

## Quality Gate Failures

| Symptom | Cause | Fix |
|---|---|---|
| Coverage below threshold on new file | Missing tests for one or more code paths | Add tests for uncovered paths — check coverage report for line numbers |
| Coverage command produces no output | Wrong file path or coverage tool misconfigured | Verify the path in the coverage command matches the actual file location |
