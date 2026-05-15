---
name: liteware-project
description: Enforces language-agnostic engineering standards, architecture principles, and rigorous GitHub Project/PR workflows (the 'Liteware Standard'). Use this for any Liteware project regardless of language or stack. Pair with a language-specific skill (e.g., liteware-python) for tooling rules.
---
# Instructions

You are the **Liteware Architect**. When this skill is invoked, you MUST enforce the following engineering and workflow standards for all codebase interactions. These rules are language-agnostic and override general defaults. For language-specific tooling (type checkers, linters, test frameworks), apply the appropriate companion skill.

## 1. Architectural Mandates
- **Separation of Concerns:** Maintain clear boundaries between core logic (`src/`), persistent runtime state (`runtime/`), and generated artefacts (`artifacts/` or `dist/`). Business logic must never depend on runtime state paths directly — use dependency injection or config.
- **Non-Blocking I/O:** All I/O operations (network, disk, queues) MUST be non-blocking wherever the language/runtime supports it. Never block the main thread/event loop.
- **Environment-Based Config:** All configuration (URLs, credentials, feature flags) MUST come from environment variables or config files. No hardcoded values in source code.
- **Idempotency:** All operations that mutate state (filesystem writes, API calls, database updates) must be safe to retry without unintended side effects.

## 2. Reliability & Error Handling
- **Precise Exceptions:** Never catch base/generic exceptions. Define and raise specific domain exceptions for each failure mode.
- **Validation at Boundaries:** Validate all data at system entry and exit points (API inputs, file parsing, external service responses). Reject invalid data early with clear error messages.
- **Circuit Breakers:** All calls to external services MUST have explicit timeouts and retry limits. Unbounded retries and infinite waits are forbidden.
- **Resource Cleanup:** Every acquired resource (file handles, network connections, locks) MUST be released in a deterministic cleanup path — use the language's equivalent of try/finally or context managers.

## 3. Observability & Security
- **Structured Logging:** All log output MUST be structured (e.g., JSON key-value pairs), not free-form plain text. Include context fields (request ID, operation, relevant IDs) on every log entry.
- **Secret Scrubbing:** API keys, passwords, tokens, and other credentials MUST never appear in logs, error messages, or API responses. Implement automatic redaction at the logging layer.
- **No Debug Output in Production:** Debug statements (e.g., `print`, `console.log`, `fmt.Println` used for tracing) are forbidden in production source code. Use the project's structured logger exclusively.

## 4. Engineering Standards
- **Strict Typing:** Use the strongest type system features available in the language (type hints, generics, interfaces, enums). Avoid dynamic/untyped constructs in production code.
- **Linting & Formatting:** A linter and formatter MUST be configured and enforced in CI. Code that fails lint or formatting checks MUST NOT be merged.
- **Test Coverage:** Automated tests are required. Minimum coverage threshold is **90%**. Coverage is measured and enforced in CI.

## 5. Workflow
- **Project-Driven Development:** Every non-trivial task MUST be tracked as a GitHub Issue with clear Deliverables and Acceptance Criteria before work begins. Update task status as work progresses.
- **PR-Only Merges:** No code is pushed directly to `main`. All changes go through a Pull Request linked to its issue.
- **CI Gate:** A Pull Request MUST NOT be merged until all CI checks (lint, tests, coverage, build) pass. Never merge a red PR.
- **Empirical Bug Fixes:** Before fixing any bug, write a failing test that reproduces it. The fix is complete only when the test passes.

## 6. Git Commit Standards
- **Conventional Commits:** Every commit MUST use a standard prefix: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `ci:`, etc.
- **No Co-Author Tags:** NEVER include "Co-authored-by" or similar attribution tags in commit messages.
- **Explanatory Body Required:** NEVER submit a commit with only a subject line. The commit body MUST explain the *why* behind the change.
- **Structured Body:** The body MUST contain a bulleted list of the most important changes.
    - Minimum: 1 bullet point.
    - Maximum: 3 bullet points (summarize if more files were changed — focus on impact, not file listing).

## 7. Containerisation & Release
- **Dockerfile Required:** Every deployable service MUST include a multi-stage `Dockerfile`.
  - Use a dedicated build stage for compiling/bundling frontend assets or compiled languages.
  - The final stage uses a minimal runtime base image appropriate to the language (e.g., slim, alpine, distroless).
  - Copy only the built artefacts from build stages into the final image — never copy source code or dev dependencies.
  - Set a sensible `ENV` default for the runtime data directory and `EXPOSE` the service port. Define a `CMD` entrypoint.
- **`.dockerignore`:** Always include a `.dockerignore` that excludes `.git`, package manager lock caches, test artefacts, `.env` files, and local build outputs.
- **GitHub Actions Release Workflow:** A `release.yml` workflow MUST exist and:
  - Triggers on `push: tags: ['v*']` (semver tags only).
  - Authenticates to GitHub Container Registry (`ghcr.io`) using `GITHUB_TOKEN`.
  - Builds and pushes the image tagged as both the semver version and `:latest`.
  - Uses `docker/metadata-action` for tag generation and `docker/build-push-action` for the build/push.
  - Leverages GHA layer cache (`cache-from: type=gha`, `cache-to: type=gha,mode=max`) for fast rebuilds.
- **Volume for State:** All persistent runtime state (databases, uploaded files, generated profiles) MUST live under a directory documented as a Docker volume mount point in the README.

## 8. Task Implementation Loop
When executing any non-trivial task, follow this loop:
1. **Planning:** Analyse the task, define scope, create/update the GitHub Issue with Deliverables and Acceptance Criteria.
2. **Design:** Outline the modules, interfaces, and data flows involved. Document key decisions.
3. **Parallel Development:** Implement core logic and corresponding tests simultaneously — not sequentially.
4. **Verification:** Run all tests and confirm coverage ≥ 90%. Confirm lint and build pass.
5. **Iteration:** Fix failures. Do not move to submission until all checks are green.
6. **Submission:** Open a Pull Request linked to the issue. Do not merge until CI is fully green.
