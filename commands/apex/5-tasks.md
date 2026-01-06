---
description: Task breakdown - divide plan into small, actionable task files
allowed-tools: Read, Write, Glob
argument-hint: [task-name]
---

You are breaking down a large plan into atomic task files. Each task should be completable in one focused session.

## Workflow

1. **Load Context**
   - Read `.claude/tasks/{task-name}/plan.md`
   - Understand the full scope and dependencies

2. **Analyze Plan Structure**
   - Identify logical groupings of steps
   - Find dependency chains
   - Estimate complexity of each group

3. **Create Task Files**
   Create files in `.claude/tasks/{task-name}/tasks/`:

   ```markdown
   # Task 01: {Task Title}

   **Complexity:** {low|medium|high}
   **Estimated steps:** {count}
   **Dependencies:** {none|task-XX}

   ## Objective
   {What this task accomplishes}

   ## Context
   {Relevant info from analysis.md needed for this task}

   ## Steps

   ### Step 1: {Step Name}
   - **File:** `path/to/file.ts`
   - **Action:** {create|modify}
   - **Details:**
     ```typescript
     // What to add/change
     ```

   ### Step 2: {Step Name}
   ...

   ## Verification
   - [ ] {How to verify step 1}
   - [ ] {How to verify step 2}

   ## Done When
   {Clear completion criteria}
   ```

4. **Create Task Index**
   Update `.claude/tasks/{task-name}/tasks/index.md`:

   ```markdown
   # Task Breakdown: {Task Name}

   **Total tasks:** {count}
   **Created:** {date}

   ## Task Order

   | # | Task | Complexity | Dependencies | Status |
   |---|------|------------|--------------|--------|
   | 01 | {title} | {low|med|high} | none | pending |
   | 02 | {title} | {low|med|high} | 01 | pending |
   | 03 | {title} | {low|med|high} | 01, 02 | pending |

   ## Dependency Graph
   ```
   01-setup
      ↓
   02-core ──→ 03-integration
      ↓            ↓
   04-tests ←──────┘
   ```

   ## Execution Order
   1. 01-setup.md (no dependencies)
   2. 02-core.md (after 01)
   3. 03-integration.md (after 01, 02)
   4. 04-tests.md (after 02, 03)
   ```

5. **Update meta.md**
   - Mark task breakdown as complete
   - Add task count

6. **Output Summary**
   ```
   Task breakdown complete for "{task-name}"

   Created {X} tasks:
   1. 01-setup.md - {description}
   2. 02-core.md - {description}
   ...

   Recommended order:
   01 → 02 → 03 → 04

   Execute with:
   /apex:3-execute {task-name} --task 01-setup.md
   ```

## Task Sizing Guidelines

### Good Task Size
- Completable in 15-30 minutes
- 1-3 files modified
- Single logical unit of work
- Clear start and end

### Too Big
- Multiple unrelated changes
- More than 5 files
- Multiple features bundled
→ Split into smaller tasks

### Too Small
- Single line change
- Trivial modifications
→ Combine with related work

## Naming Convention

```
01-{category}-{description}.md

Categories:
- setup     (initial configuration)
- core      (main implementation)
- api       (API/backend changes)
- ui        (frontend/UI changes)
- data      (database/models)
- test      (testing)
- docs      (documentation)
- fix       (bug fixes)
- refactor  (code improvements)
```

## Rules

- Each task must be SELF-CONTAINED with all needed context
- Include relevant code snippets from plan.md
- Dependencies must be explicit
- Verification criteria must be concrete
- Tasks should be executable in any new conversation
