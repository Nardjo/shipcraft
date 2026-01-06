---
description: Execution phase - implement the plan step by step
allowed-tools: Task, Read, Write, Edit, Glob, Grep, Bash, TodoWrite, mcp__exa__get_code_context_exa, mcp__context7__get-library-docs
argument-hint: [task-name] [--step X.Y] [--task task-file]
---

You are implementing the plan. Execute precisely what was planned, step by step.

## Workflow

1. **Load Context**
   - Read `.claude/tasks/{task-name}/meta.md`
   - Read `.claude/tasks/{task-name}/plan.md` - this is your roadmap
   - If `--task` provided: read specific task file from `tasks/` folder
   - If `--step` provided: jump to that specific step

2. **Setup Tracking**
   - Use `TodoWrite` to track steps from plan.md
   - Mark current step as in_progress

3. **Execute Steps**
   For each step in plan:

   a. **Read step requirements** from plan.md

   b. **Verify prerequisites** are complete

   c. **Implement** the changes:
      - Follow the plan exactly
      - Use patterns documented in analysis.md
      - Create/modify files as specified

   d. **Verify** step completion:
      - Run type checks if TypeScript
      - Run linter if applicable
      - Fix any immediate errors

   e. **Mark complete** in TodoWrite

   f. **Update plan.md** checklist

4. **Handle Blockers**
   - If blocked, document in meta.md
   - Ask user if decision needed
   - Don't deviate from plan without explicit approval

5. **Progress Report**
   After each phase or significant progress:
   ```
   Progress: {X}/{Y} steps complete

   Completed:
   - [x] Step 1.1: {description}
   - [x] Step 1.2: {description}

   Current:
   - [ ] Step 2.1: {description}

   Issues: {any blockers}
   ```

6. **Completion**
   When all steps done:
   - Update meta.md status
   - **Update CHANGELOG.md** at project root (create if missing)
   - Output summary of all changes
   - Suggest running /apex:4-examine

7. **Changelog Entry**
   ```markdown
   ## [YYYY-MM-DD]

   ### {Type}: {Task name from meta.md}

   **Files changed:**
   - `path/to/file.ts` - {what changed}

   **Summary:** {Brief description from plan}

   ---
   ```
   Types: `feat`, `fix`, `refactor`, `style`, `docs`, `perf`, `test`

## Execution Modes

### Full Execution (default)
```
/apex:3-execute feature-name
```
Runs all steps from plan.md sequentially.

### Single Step
```
/apex:3-execute feature-name --step 2.1
```
Runs only step 2.1.

### From Task File
```
/apex:3-execute feature-name --task 01-setup.md
```
Runs steps defined in a specific task file from /apex:5-tasks.

## Rules

- **FOLLOW THE PLAN** - Don't improvise or add features
- **ONE STEP AT A TIME** - Complete and verify before moving on
- **DOCUMENT DEVIATIONS** - If you must deviate, note it in meta.md
- **ASK WHEN BLOCKED** - Don't make assumptions on unclear points
- **VERIFY EACH STEP** - Run checks after each change

## Output Style

Minimal commentary during execution:
```
[Step 1.1] Creating auth/types.ts...
[Step 1.1] Done ✓

[Step 1.2] Modifying auth/index.ts...
[Step 1.2] TypeScript error - fixing...
[Step 1.2] Done ✓

Progress: 2/8 steps
```
