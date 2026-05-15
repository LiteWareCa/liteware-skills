# Liteware Skills

Portable AI coding-assistant skills that encode **Liteware engineering standards** — workflow, architecture principles, and language-specific tooling rules. Drop these into your AI assistant to get consistent, opinionated guidance across every Liteware project.

## Skills

| Skill | Scope | Use when |
|---|---|---|
| [`liteware-project`](./liteware-project/SKILL.md) | Language-agnostic | Every Liteware project |
| [`liteware-python`](./liteware-python/SKILL.md) | Python-specific | Any project with a Python backend |

### Skill hierarchy

`liteware-project` is the foundation — it covers architecture, reliability, observability, workflow, git standards, containerisation, and the task implementation loop for **any** language or stack.

`liteware-python` (and future language skills) layer on top, adding ecosystem-specific tooling: which linter, which test framework, which base Docker image, etc.

---

## Installation

### GitHub Copilot CLI

```bash
# Clone into the Copilot skills directory
git clone https://github.com/LiteWareCa/liteware-skills ~/.copilot/skills-repo

# Symlink (or copy) the skills you want into the skills directory
ln -s ~/.copilot/skills-repo/liteware-project ~/.copilot/skills/liteware-project
ln -s ~/.copilot/skills-repo/liteware-python  ~/.copilot/skills/liteware-python
```

Or use the install script (see below).

### Claude Code

Add the skill content to your project's `CLAUDE.md` or your user-level `~/.claude/CLAUDE.md`:

```bash
# Append both skills to your user-level Claude instructions
cat liteware-project/SKILL.md liteware-python/SKILL.md >> ~/.claude/CLAUDE.md
```

### Gemini CLI

```bash
# Place skills in the Gemini skills directory
cp -r liteware-project liteware-python ~/.gemini/skills/
```

---

## Install Script

The `install.sh` script automates installation for a given tool:

```bash
# Install for Copilot CLI (default)
./install.sh

# Install for a specific tool
./install.sh --tool copilot
./install.sh --tool claude
./install.sh --tool gemini

# Install specific skills only
./install.sh --skills liteware-project,liteware-python --tool copilot
```

---

## Updating

```bash
cd ~/.copilot/skills-repo   # or wherever you cloned
git pull
```

If you used symlinks, the update is instant. If you copied files, re-run `install.sh`.

---

## Adding a New Language Skill

1. Create a directory: `liteware-<language>/`
2. Add `SKILL.md` with YAML frontmatter (`name`, `description`) and the skill instructions
3. Reference it from this README
4. Open a PR

---

## Standards Summary

### `liteware-project` covers
- Architecture: concern separation, non-blocking I/O, env-based config, idempotency
- Reliability: specific exceptions, boundary validation, circuit breakers, resource cleanup
- Observability: structured JSON logging, secret scrubbing, no debug output in production
- Engineering: strict typing, linting/formatting + ≥90% coverage enforced in CI
- Workflow: issue-driven development, PR-only merges, CI gate before merge, empirical bug fixes
- Git: conventional commits, explanatory body (1–3 bullet points), no co-author tags
- Containerisation: multi-stage Dockerfile, `.dockerignore`, `release.yml` on `v*` tags → `ghcr.io`
- Task Loop: plan → design → parallel dev+tests → verify → iterate → PR

### `liteware-python` adds
- `asyncio`-native I/O — no blocking calls in async contexts
- `pydantic-settings` for config — no raw `os.environ` in business logic
- Pydantic v2 validation at all system boundaries
- `async with` / `with` for all resources
- `structlog` / `logging` — `print()` forbidden in `src/`
- `ruff` (lint + isort) + `black` (format), both enforced in CI
- Full PEP 484 type hints — mypy/pyright strict, no bare `Any`
- pytest + pytest-asyncio + pytest-cov — ≥90% coverage
- `python:3.11-slim`+ base image, `uv` for installs, layer-caching `pyproject.toml`
