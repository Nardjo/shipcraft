# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Shipcraft is a **Claude Code plugin** (not a runtime application). It ships specialized subagents, slash commands, and one shell script. There is no build step, no test suite, no package manager — the artifacts are Markdown files and a Bash script consumed by the Claude Code harness.

- Plugin manifest: `.claude-plugin/plugin.json` (must be kept in sync with `.claude-plugin/marketplace.json` — both carry a `version` field)
- Distribution: `/plugin marketplace add Nardjo/shipcraft` then `/plugin install shipcraft`

## Architecture

Three artifact types, each loaded by Claude Code by convention from its directory:

1. **`agents/*.md`** — subagent definitions (frontmatter + system prompt). Each agent is a single-purpose role (e.g., `requirement-parser`, `cto-advisor`, `implementer`). Agents are invoked via `Task(subagent_type: "...")` from orchestrator commands.
2. **`commands/*.md`** — slash commands. The top-level orchestrators are `rpi.md`, `debug.md`, `oneshot.md`. `commands/git/*.md` are git utilities. Frontmatter declares `allowed-tools` and `argument-hint`.
3. **`scripts/ralph-loop.sh`** + **`templates/ralph-prompt.md`** — the Ralph autonomous loop. Spawns headless `claude --print` iterations against `.rpi/plan.md`, one plan-step per iteration, fresh context each time, until the prompt emits `<PROMISE>COMPLETE</PROMISE>` or `--max N` is hit (default 25).

### The RPI workflow (the core product)

`/rpi` is an orchestrator command that coordinates other agents. **Light mode is the default** — the heavy 6-agent flow is opt-in via `--full`.

Light (default):
```
ANALYSE → PLAN → [BLOCKING USER APPROVAL] → IMPLEMENT → VERIFY
```

Full (`--full`):
```
RESEARCH (parallel: requirement-parser + product-manager + senior-engineer)
   → GO/NO-GO (cto-advisor — SKIPPED on consensus GO)
   → PLAN (planner)
   → [BLOCKING USER APPROVAL]
   → EXECUTE (implementer OR parallel snippers OR ralph OR team)
   → VERIFY (single agent: build + code review + requirements)
```

**Shared exploration via `.rpi/context.md`** — the first explorer (analyser in light, requirement-parser in full) writes its full report to disk. Downstream agents read this file instead of re-grepping. The orchestrator passes only TL;DR summaries between phases. Don't reintroduce duplicate exploration.

Mode flags **combine**:
- `--ralph` — hands execution to `scripts/ralph-loop.sh` (fresh context per step, default `--max 15`)
- `--team` — Phase 3 uses `TeamCreate` + `TaskCreate` + 2–4 parallel `implementer` teammates
- `--worktree` — wraps the entire workflow in `EnterWorktree`/`ExitWorktree`, prompts merge/keep/discard at the end

Model assignments are intentional in `commands/rpi.md`:
- **opus** for synthesis-heavy roles: `senior-engineer`, `cto-advisor`, `planner`
- **sonnet** for execution + verification: `requirement-parser`, `product-manager`, `implementer`, `snipper`, `verifier`
- **haiku** for the light-mode `analyser`

The `verifier` is a **fused agent** (replaces the previous separate `code-reviewer` + `verifier`): single pass for build checks, diff review, and requirement validation. Don't split it back.

### Ralph loop contract

`scripts/ralph-loop.sh` requires `.rpi/plan.md` and `.rpi/ralph-prompt.md` in the project where it runs (NOT here). It appends iteration tails to `.rpi/progress.md`. The completion sentinel is the literal string `<PROMISE>COMPLETE</PROMISE>` — the prompt template at `templates/ralph-prompt.md` is responsible for emitting it when the plan is done. Don't change the sentinel without updating both sides.

## Conventions when editing

- **Agent prompts** are the product. Treat changes to `agents/*.md` and `commands/*.md` as you would code: keep them tight, preserve the frontmatter shape (`description`, `allowed-tools`, `argument-hint`, `model` where present).
- **User approval is BLOCKING** in `/rpi` — never edit the orchestrator to skip the approval gate. Same for the GO/NO-GO halt.
- **Bump versions in lockstep**: `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` must agree. CHANGELOG.md tracks releases.
- **Routing**: `/oneshot` for trivial fixes, `/debug` for bugs, `/rpi` for everything that needs planning. Don't add new top-level commands without considering whether they belong inside an existing flow.
