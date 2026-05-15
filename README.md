# Liteware Skills

[Agent Skills](https://agentskills.io) that encode **Liteware engineering standards** — workflow, architecture principles, and language-specific tooling rules. Drop these into any compatible AI coding assistant to get consistent, opinionated guidance across every Liteware project.

> **Agent Skills** is an open standard originally created by Anthropic, supported by GitHub Copilot CLI, Claude Code, Gemini CLI, Cursor, Windsurf, OpenCode, and more. A skill is a folder containing a `SKILL.md` file with metadata and instructions that the agent loads on demand.

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

### GitHub Copilot CLI — via `gh skill` (recommended)

The cleanest install uses the [`gh skill`](https://cli.github.com/manual/gh_skill) command (GitHub CLI ≥ v2.90):

```bash
# Preview a skill before installing
gh skill preview LiteWareCa/liteware-skills liteware-project

# Install as personal skills (available in all projects)
gh skill install LiteWareCa/liteware-skills liteware-project
gh skill install LiteWareCa/liteware-skills liteware-python

# Or install both in one interactive flow
gh skill install LiteWareCa/liteware-skills
```

Skills are installed to `~/.copilot/skills/` by default. They will appear in `/skills list` inside the CLI.

To update later:
```bash
gh skill update --all
```

### GitHub Copilot CLI — manual install

If you prefer not to use `gh skill`:

```bash
git clone https://github.com/LiteWareCa/liteware-skills
cp -r liteware-skills/skills/liteware-project ~/.copilot/skills/
cp -r liteware-skills/skills/liteware-python  ~/.copilot/skills/
```

Then inside the CLI, run `/skills reload` to pick them up without restarting.

> **`/skills add`** adds an alternative *local directory* to search for skills — it does not accept URLs. Use `gh skill install` for URL-based install.

### Project-level skills (any tool)

To apply these skills automatically to a specific project — without installing them globally — copy them into your repository:

```bash
# Works with Copilot CLI, Claude Code, Gemini CLI, and VS Code agent mode
mkdir -p .github/skills
cp -r ~/.copilot/skills/liteware-project .github/skills/
cp -r ~/.copilot/skills/liteware-python  .github/skills/
```

Any of these directories are scanned automatically:
- `.github/skills/` — standard, picked up by Copilot CLI and Claude Code
- `.claude/skills/` — Claude Code and Copilot CLI
- `.agents/skills/` — universal

### Claude Code — native skills support

Claude Code supports Agent Skills natively via the `/plugin` command:

```
/plugin marketplace add LiteWareCa/liteware-skills
```

Then install individual skills:

```
/plugin install liteware-project@liteware-skills
/plugin install liteware-python@liteware-skills
```

Or install directly to `~/.claude/skills/`:

```bash
gh skill install LiteWareCa/liteware-skills liteware-project --agent claude-code --scope user
gh skill install LiteWareCa/liteware-skills liteware-python  --agent claude-code --scope user
```

### Gemini CLI

```bash
git clone https://github.com/LiteWareCa/liteware-skills
cp -r liteware-skills/skills/liteware-project ~/.gemini/skills/
cp -r liteware-skills/skills/liteware-python  ~/.gemini/skills/
```

---

## Compatibility

| Tool | Recommended install | Personal skill path | Project skill path |
|------|--------------------|--------------------|-------------------|
| GitHub Copilot CLI | `gh skill install LiteWareCa/liteware-skills <skill>` | `~/.copilot/skills/` | `.github/skills/`, `.claude/skills/`, `.agents/skills/` |
| Claude Code | `/plugin marketplace add LiteWareCa/liteware-skills` | `~/.claude/skills/` | `.github/skills/`, `.claude/skills/` |
| Gemini CLI | copy | `~/.gemini/skills/` | `.github/skills/` |
| VS Code (agent mode) | `gh skill install` | `~/.copilot/skills/` | `.github/skills/` |
| Cursor / Windsurf | copy | tool-specific | `.github/skills/` |

All tools respect the [Agent Skills](https://agentskills.io) open standard (`SKILL.md` with YAML frontmatter).

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

