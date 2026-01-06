---
description: Debug bugs with systematic analysis using specialized agents
allowed-tools: Task, Bash, AskUserQuestion, mcp__claude-in-chrome__tabs_context_mcp, mcp__claude-in-chrome__tabs_create_mcp, mcp__claude-in-chrome__navigate, mcp__claude-in-chrome__read_console_messages, mcp__claude-in-chrome__read_network_requests, mcp__claude-in-chrome__computer, mcp__claude-in-chrome__javascript_tool, mcp__claude-in-chrome__read_page
argument-hint: <bug-description> [--url <app-url>]
---

You are a debugging orchestrator. Coordinate specialized agents to diagnose and fix bugs systematically.

## Workflow Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  DIAGNOSE   │───▶│    PLAN     │───▶│     FIX     │───▶│   VERIFY    │
│  analyser   │    │   planner   │    │   snipper   │    │  verifier   │
│   (haiku)   │    │  (optional) │    │   (haiku)   │    │   (haiku)   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │
                   (skip if simple)
```

## Phase 1: DIAGNOSE

Launch analyser to investigate the bug:

```
Task(
  subagent_type: "analyser",
  prompt: "Debug investigation: [BUG DESCRIPTION]

  Find:
  - Error messages and stack traces in code
  - Related files and components
  - Recent changes to affected area (git log)
  - Similar patterns or past fixes

  Return diagnosis with root cause hypothesis."
)
```

**Browser inspection** (if UI bug or --url provided):
- `read_console_messages` with pattern for errors
- `read_network_requests` for API failures
- `computer` screenshot to capture visual state
- `javascript_tool` to inspect runtime state

**Combine findings** into diagnosis summary.

## Phase 2: PLAN (optional)

**Skip if:** Simple bug with obvious fix (typo, missing import, wrong value)

**Use planner if:** Complex bug requiring multiple file changes

```
Task(
  subagent_type: "planner",
  prompt: "Plan fix for: [BUG DESCRIPTION]

  Diagnosis:
  [DIAGNOSIS FROM PHASE 1]

  Create minimal fix plan - only what's needed to resolve the bug."
)
```

## Phase 3: FIX

Launch snipper to apply the fix:

```
Task(
  subagent_type: "snipper",
  prompt: "Fix bug: [BUG DESCRIPTION]

  Root cause: [FROM DIAGNOSIS]

  Files to modify:
  - [file1]: [change needed]
  - [file2]: [change needed]

  Apply minimal fix. No refactoring, no improvements."
)
```

## Phase 4: VERIFY

Launch verifier to confirm fix:

```
Task(
  subagent_type: "verifier",
  prompt: "Verify bug fix: [BUG DESCRIPTION]

  Changes made:
  [FROM SNIPPER OUTPUT]

  Run checks and confirm bug is resolved."
)
```

**Browser verification** (if UI bug):
- Refresh page
- Check console is clean
- Screenshot to confirm visual fix

## Bug Type Strategies

### TypeScript Errors
1. Run `pnpm typecheck` to get errors
2. Diagnose → Snipper (usually simple)
3. Re-run typecheck to verify

### UI/Visual Bugs
1. Screenshot before
2. Console + Network inspection
3. Diagnose → Plan (if complex) → Snipper
4. Screenshot after to verify

### Runtime Errors
1. Console messages + stack trace
2. Diagnose root cause
3. Snipper fix
4. Verify no console errors

### CI/CD Failures
1. Parse CI logs for actual error
2. Reproduce locally if possible
3. Diagnose → Fix → Verify CI passes

## Quick Mode

For obvious bugs, skip to snipper directly:

```
Task(
  subagent_type: "snipper",
  prompt: "Quick fix: [OBVIOUS BUG]
  File: [path]
  Change: [what to fix]"
)
```

## Output Format

```
## Bug Fixed ✓

**Issue:** [Original bug description]
**Root Cause:** [What was wrong]
**Fix:** [What was changed]

**Files Modified:**
- `path/to/file.ts` - [change]

**Verified:** [How it was tested]
```

## Rules

- **DIAGNOSE FIRST** - Understand before fixing
- **MINIMAL FIXES** - Only what's needed
- **ALWAYS VERIFY** - Never assume it works
- **NO SIDE QUESTS** - Stay focused on the bug
