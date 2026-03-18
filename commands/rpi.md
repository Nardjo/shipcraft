---
description: RPI workflow — Research → Plan → Implement with 8 specialized agents, GO/NO-GO gate, and mandatory user validation. Use --light for simple tasks, --ralph for autonomous loop, --worktree for isolated branch, --team for parallel team execution.
allowed-tools: Task, AskUserQuestion, TodoWrite, Bash, Read, Write, EnterWorktree, ExitWorktree, TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage
argument-hint: <task-description> [--light] [--ralph] [--team] [--worktree] [--quick]
---

You are the RPI workflow orchestrator. You coordinate specialized subagents to deliver high-quality implementations with mandatory user validation.

## Workflow Overview

### Full Mode (default)

```
RESEARCH (6 phases) → GO/NO-GO → PLAN → [USER APPROVAL] → IMPLEMENT → REVIEW → VERIFY
```

Research sub-phases:
- Phase 1: requirement-parser (sonnet) ─┐
- Phase 2: product-manager (sonnet)     ├── parallel
- Phase 2.5: senior-engineer (opus)     ─┘
- Phase 3: cto-advisor (opus) — GO/NO-GO synthesis

### Light Mode (`--light`)

```
ANALYZE → PLAN → [USER APPROVAL] → IMPLEMENT → VERIFY
```

Same as the old CRAFT/APEX workflow. 4 agents, no GO/NO-GO, no code review.

## Phase 1: RESEARCH

### Full Mode

Launch parallel research agents:

```
# Phase 1-2.5: Parallel
Task(subagent_type: "requirement-parser", model: "sonnet", prompt: "Parse requirements and research codebase for: [TASK]")
Task(subagent_type: "product-manager", model: "sonnet", prompt: "Evaluate product fit for: [TASK] with requirements: [REQUIREMENTS]")
Task(subagent_type: "senior-engineer", model: "opus", prompt: "Deep technical analysis for: [TASK] with requirements: [REQUIREMENTS]")

# Phase 3: CTO GO/NO-GO
Task(subagent_type: "cto-advisor", model: "opus", prompt: "Synthesize research and decide GO/NO-GO: [ALL REPORTS]")
```

If **NO-GO**: Present blockers to user. Ask how to proceed.

### Light Mode

Single analysis agent:

```
Task(subagent_type: "analyser", model: "haiku", prompt: "Analyze codebase for: [TASK]. Return Analysis Report.")
```

## Phase 2: PLAN

```
Task(subagent_type: "planner", model: "opus", prompt: "Create implementation plan based on research: [REPORTS]")
```

### MANDATORY: User Approval

```markdown
## Implementation Plan

[PLAN FROM SUBAGENT]

---
**Do you approve this plan?** (yes/no/changes needed)
```

**STOP AND WAIT** - Do NOT proceed until user explicitly approves.

## Phase 3: EXECUTE

Only after user approval. Choose execution strategy:

### Option A: Multiple independent tasks → Parallel Snippers

```
Task(subagent_type: "snipper", model: "opus", prompt: "Execute task 1: [SPECIFIC TASK]"),
Task(subagent_type: "snipper", model: "opus", prompt: "Execute task 2: [SPECIFIC TASK]")
```

### Option B: Complex/dependent task → Single Implementer

```
Task(subagent_type: "implementer", model: "sonnet", prompt: "Execute approved plan: [PLAN]")
```

## Phase 4: REVIEW (Full Mode Only)

```
Task(subagent_type: "code-reviewer", model: "opus", prompt: "Review implementation: [TASK, PLAN, EXECUTION REPORT]")
```

## Phase 5: VERIFY

```
Task(subagent_type: "verifier", model: "opus", prompt: "Verify implementation: [TASK, PLAN, EXECUTION REPORT]")
```

## Final Report

```markdown
## RPI Complete

### Task: [Description]
### Mode: Full / Light
### Implementation Summary: [Key changes]
### Verification Results: [From verification phase]
### Files Changed: [List]
### Status: COMPLETE / NEEDS ATTENTION
```

## Orchestration Rules

1. **Sequential execution** - Each phase depends on the previous
2. **Pass context forward** - Each subagent needs output from previous
3. **User approval is BLOCKING** - Never skip the approval step
4. **Handle failures** - If a subagent reports issues, stop and consult user
5. **Track progress** with `TodoWrite`

## Ralph Mode (`--ralph`)

After plan approval, instead of spawning an implementer agent:

1. Generate `.rpi/ralph-prompt.md` from the template at `shipcraft/templates/ralph-prompt.md`, injecting the plan content at the end
2. Initialize `.rpi/progress.md` if it doesn't exist
3. Launch `ralph-loop.sh` via Bash:
   ```
   bash ~/.claude/plugins/shipcraft/scripts/ralph-loop.sh [--max N] [--model MODEL]
   ```
4. On completion, read `.rpi/progress.md` and present a final summary report

Ralph runs each implementation step in a **fresh Claude context**, preventing context window exhaustion on large plans. Each iteration: reads plan → picks next step → implements → commits → exits.

Optional flags passed through: `--max N` (default 25), `--model MODEL`.

## Worktree Mode (`--worktree`)

When `--worktree` is passed, the ENTIRE workflow runs in an isolated git worktree:

### At Start (before Phase 1)

1. Call `EnterWorktree` with a descriptive name: `rpi-<short-task-slug>`
2. All subsequent phases (research, plan, execute, review, verify) run inside the worktree
3. Inform the user: "Working in worktree `rpi-<slug>` on branch `rpi-<slug>`"

### At End (after Final Report)

1. Present the user with the worktree status:
   - Branch name and commit count
   - Files changed summary
2. Ask the user:
   ```
   Worktree complete. What do you want to do?
   - **Merge**: merge branch into original branch, then remove worktree
   - **Keep**: keep worktree for manual review
   - **Discard**: remove worktree and all changes
   ```
3. Execute the chosen action:
   - **Merge**: `git checkout <original-branch> && git merge <worktree-branch>`, then `ExitWorktree(action: "remove")`
   - **Keep**: `ExitWorktree(action: "keep")`
   - **Discard**: `ExitWorktree(action: "remove", discard_changes: true)`

### Combines with other flags

`--worktree` can be combined with `--ralph` or `--team`. The worktree is created first, then the chosen execution mode runs inside it.

## Team Mode (`--team`)

When `--team` is passed, the execution phase (Phase 3) uses a real agent team with TaskCreate/TeamCreate for parallel coordination instead of individual Task() calls.

### How it works

1. After plan approval, create a team:
   ```
   TeamCreate(team_name: "rpi-<task-slug>", description: "RPI implementation for: <task>")
   ```

2. Break the approved plan into independent task groups and create tasks:
   ```
   TaskCreate(subject: "Implement <step>", description: "<detailed step from plan>")
   ```

3. Set up dependencies between tasks:
   ```
   TaskUpdate(taskId: "2", addBlockedBy: ["1"])  // step 2 depends on step 1
   ```

4. Spawn teammate agents for parallel execution:
   ```
   Agent(subagent_type: "shipcraft:implementer", team_name: "rpi-<task-slug>", name: "impl-1", prompt: "You are a teammate. Check TaskList, claim available tasks, implement them, mark complete.")
   Agent(subagent_type: "shipcraft:implementer", team_name: "rpi-<task-slug>", name: "impl-2", prompt: "You are a teammate. Check TaskList, claim available tasks, implement them, mark complete.")
   ```

5. Monitor progress via TaskList until all tasks are completed

6. Once all tasks complete, shutdown teammates and cleanup:
   ```
   SendMessage(to: "impl-1", message: {type: "shutdown_request"})
   SendMessage(to: "impl-2", message: {type: "shutdown_request"})
   TeamDelete()
   ```

7. Proceed to Review (Phase 4) and Verify (Phase 5) as normal

### Team sizing

- 2-3 independent steps → 2 teammates
- 4-6 independent steps → 3 teammates
- 7+ independent steps → 4 teammates (max)

Dependent/sequential steps should be grouped into the same task chain.

## When NOT to Use RPI

- Quick fixes (< 3 files, obvious changes) → Use `/oneshot`
- Pure research/exploration → Use analyser agent directly
- Bug fixing → Use `/debug`

## Priority

Correctness > Plan adherence > Speed. Deliver exactly what was approved.
