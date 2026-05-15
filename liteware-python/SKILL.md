---
name: liteware-python
description: Python-specific engineering rules for Liteware projects. Covers asyncio, pydantic-settings, ruff/black, type hints, pytest, and Docker base images. Always pair with the liteware-project skill for workflow and architecture standards.
---
# Instructions

You are enforcing **Liteware Python Standards**. These rules apply to any Liteware project whose backend or primary codebase is Python. They complement — and never replace — the `liteware-project` skill. When both skills are active, both sets of rules apply.

## 1. Async Runtime
- All I/O MUST use `asyncio`-native libraries (e.g., `httpx`, `aiofiles`, `asyncpg`). Never call blocking functions (`time.sleep`, synchronous `open()` for large reads, `requests`) inside an `async def` context.
- Use `asyncio.gather()` for concurrent independent operations. Avoid sequential `await` chains where parallelism is possible.
- Background tasks that outlive a request MUST be managed via `asyncio.create_task()` or a task queue — not bare threads.

## 2. Configuration
- Use `pydantic-settings` (`BaseSettings`) for all application configuration. Configuration classes live in `src/<package>/config.py`.
- Never read `os.environ` directly in business logic. All env var access goes through the settings object.
- Provide sensible defaults for every setting. Document required (no-default) settings clearly in the README.

## 3. Data Validation
- Use Pydantic v2 models for all API request/response schemas and core domain models.
- Validate at every system boundary: HTTP input, file parsing output, external API responses.
- Use `model_validator` / `field_validator` for cross-field and complex constraints — never validate inside route handlers.

## 4. Resource Management
- Use `async with` for all async resources (HTTP clients, database sessions, file handles via `aiofiles`).
- Use `with` for synchronous resources. Never rely on garbage collection for resource release.
- Define `__aenter__` / `__aexit__` (or use `contextlib.asynccontextmanager`) for any class that owns a resource.

## 5. Logging
- Use `structlog` (preferred) or the stdlib `logging` module with a JSON formatter. Configuration lives in `src/<package>/log.py`.
- `print()` is **forbidden** in any file under `src/`. Use the configured logger.
- Bind contextual fields (request ID, speaker ID, operation name) to the logger at the start of each operation using `structlog.contextvars` or `logging.LoggerAdapter`.
- Never log raw exception objects with sensitive payloads — scrub before logging.

## 6. Code Style
- **Ruff** is the linter and import sorter. Configuration in `pyproject.toml` under `[tool.ruff]`.
- **Black** is the formatter. Configuration in `pyproject.toml` under `[tool.black]`.
- Both MUST run in CI (lint job) and fail the build on any violation.
- Suggested minimum ruff rules: `E`, `F`, `I`, `UP`, `B`, `C4`, `SIM`.

## 7. Type Safety
- Full PEP 484 type hints are mandatory on all public functions, methods, and class attributes.
- Code must be compatible with `mypy --strict` or `pyright` in basic mode. No unresolved `Any` in production source.
- Use `TypeVar`, `Generic`, `Protocol`, and `TypedDict` where appropriate instead of loosening types.
- Never use `# type: ignore` without an inline comment explaining why.

## 8. Testing
- Use **pytest** as the test runner. Async tests use **pytest-asyncio** with `asyncio_mode = "auto"` in `pyproject.toml`.
- Coverage is measured with **pytest-cov**. The CI test job MUST fail if coverage drops below **90%**.
- Test files live in `tests/`. Mirror the `src/` package structure (e.g., `tests/ingestion/test_parser.py`).
- Use `pytest.fixture` for shared setup. Prefer `httpx.AsyncClient` with `ASGITransport` for API integration tests — no running server needed.
- Follow the empirical fix rule from `liteware-project`: write a failing test before writing the fix.

## 9. Docker (Python-Specific)
- The final Docker stage MUST use `python:3.11-slim` or a newer slim variant as the base image. Never use full Debian/Ubuntu images for production.
- Use `uv` (preferred) or `pip` with `--no-cache-dir` to install dependencies. If using `uv`, install it in a dedicated stage.
- Copy `pyproject.toml` (and `README.md` if required by the build backend) **before** copying source code to maximise layer caching.
- Do not install dev/test dependencies in the final image. Use `--no-dev` (uv) or a separate extras group.
- The `CMD` should invoke `uvicorn` directly (e.g., `uvicorn myapp.api.app:app --host 0.0.0.0 --port 8000`).
