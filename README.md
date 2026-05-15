# Liteware Skills

[Agent Skills](https://agentskills.io) that encode **Liteware engineering standards** — workflow, architecture principles, and language-specific tooling rules. Drop these into any compatible AI coding assistant to get consistent, opinionated guidance across every Liteware project.

> **Agent Skills** is an open standard originally created by Anthropic, supported by Claude Code, GitHub Copilot CLI, Gemini CLI, Cursor, Windsurf, OpenCode, and more. A skill is a folder containing a `SKILL.md` file with metadata and instructions that the agent loads on demand.

## Skills

| Skill | Scope | Use when |
|---|---|---|
| [`liteware-project`](./skills/liteware-project/SKILL.md) | Language-agnostic | Every Liteware project |
| [`liteware-python`](./skills/liteware-python/SKILL.md) | Python-specific | Any project with a Python backend |

### Skill hierarchy

`liteware-project` is the foundation — architecture, reliability, observability, workflow, git standards, containerisation, and the task implementation loop for **any** language or stack.

`liteware-python` layers on top with Python-specific tooling: asyncio, pydantic-settings, ruff/black, pytest, Docker base images, etc.

---

## Installation

### Claude Code (recommended — native skills support)

Claude Code supports Agent Skills natively via the `/plugin` command:

```
/plugin marketplace add LiteWareCa/liteware-skills
```

Then install individual skills:

```
/plugin install liteware-project@liteware-skills
/plugin install liteware-python@liteware-skills
```

Or place skill files directly in `~/.claude/skills/`:

```bash
git clone https://github.com/LiteWareCa/liteware-skills
cp -r liteware-skills/skills/liteware-project ~/.claude/skills/
cp -r liteware-skills/skills/liteware-python  ~/.claude/skills/
```

### GitHub Copilot CLI

Copilot CLI loads skills from `~/.copilot/skills/`. Use the `/skills` command inside the CLI to manage them, or install manually:

```bash
git clone https://github.com/LiteWareCa/liteware-skills
cp -r liteware-skills/skills/liteware-project ~/.copilot/skills/
cp -r liteware-skills/skills/liteware-python  ~/.copilot/skills/
```

> **Tip:** Copilot CLI also reads `CLAUDE.md`, `GEMINI.md`, and `AGENTS.md` from the repository root and your home config. You can paste skill content into any of these files as an alternative to the skills directory.

### Gemini CLI

```bash
git clone https://github.com/LiteWareCa/liteware-skills
cp -r liteware-skills/skills/liteware-project ~/.gemini/skills/
cp -r liteware-skills/skills/liteware-python  ~/.gemini/skills/
```

### Any compatible tool (install script)

```bash
git clone https://github.com/LiteWareCa/liteware-skills
cd liteware-skills

./install.sh                      # GitHub Copilot CLI (default)
./install.sh --tool claude        # Claude Code → ~/.claude/skills/
./install.sh --tool gemini        # Gemini CLI → ~/.gemini/skills/

# Install specific skills only
./install.sh --tool copilot --skills liteware-project
```

---

## Updating

```bash
cd /path/to/liteware-skills
git pull
./install.sh --tool <your-tool>   # re-run to apply updates
```

---

## Adding a New Language Skill

1. Create `skills/liteware-<language>/SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: liteware-<language>
   description: <language>-specific engineering rules for Liteware projects. ...
   ---
   ```
2. Add skill instructions below the frontmatter
3. Add an entry to this README's skills table
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

---

## Compatibility

| Tool | Install method | Skill path |
|------|---------------|-----------|
| Claude Code | `/plugin marketplace add LiteWareCa/liteware-skills` | `~/.claude/skills/` |
| GitHub Copilot CLI | `/skills` command or copy | `~/.copilot/skills/` |
| Gemini CLI | Copy | `~/.gemini/skills/` |
| Cursor / Windsurf / OpenCode | Copy | Tool-specific skills dir |

All tools respect the [Agent Skills](https://agentskills.io) open standard (`SKILL.md` with YAML frontmatter).
