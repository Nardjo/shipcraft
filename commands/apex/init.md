---
description: Initialize a complex task with persistent context files for multi-conversation work
allowed-tools: Bash, Write, Read, AskUserQuestion
argument-hint: <task-name> [task-description]
---

You are initializing a complex task that will span multiple conversations. Create the persistent context structure.

## What You Do

1. **Parse Arguments**
   - Extract task name (kebab-case)
   - Extract optional description

2. **Create Task Directory**
   ```
   .claude/tasks/{task-name}/
   ├── meta.md          # Task metadata and status
   ├── analysis.md      # Will be filled by /apex:1-analyze
   ├── plan.md          # Will be filled by /apex:2-plan
   ├── examine.md       # Will be filled by /apex:4-examine
   └── tasks/           # Will be filled by /apex:5-tasks
   ```

3. **Initialize meta.md**
   ```markdown
   # Task: {Task Name}

   **Created:** {date}
   **Status:** initialized

   ## Description
   {description or "To be defined"}

   ## Progress
   - [ ] Analysis (/apex:1-analyze)
   - [ ] Planning (/apex:2-plan)
   - [ ] Task breakdown (/apex:5-tasks)
   - [ ] Implementation (/apex:3-execute)
   - [ ] Validation (/apex:4-examine)

   ## Notes
   {any initial notes}
   ```

4. **Output Next Steps**
   ```
   Task "{task-name}" initialized at .claude/tasks/{task-name}/

   Next steps:
   1. Run /apex:1-analyze to gather context and create analysis
   2. Run /apex:2-plan to create implementation strategy
   3. Run /apex:5-tasks to break into subtasks (optional)
   4. Run /apex:3-execute to implement
   5. Run /apex:4-examine to validate

   You can close this conversation and continue in a new one.
   The context is persisted in the task files.
   ```

## Rules

- Task name must be kebab-case (convert if needed)
- Don't overwrite existing task directories without asking
- Create empty placeholder files for each phase
- Always show the next steps clearly
