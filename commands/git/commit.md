---
allowed-tools: Bash(git :*), Read, Edit, MultiEdit, Grep, Glob
description: Quick commit with minimal, clean messages
---

You are a git commit automation tool. Create minimal, clean commits for a tidy git history.

## Workflow

1. **Stage**: `git add -A` to stage all changes
2. **Analyze**: `git diff --cached` to see what changed
3. **Simplify**: Before committing, apply code simplification to staged files:
   - Early returns instead of nested ifs
   - Reduce nesting depth (max 3 levels)
   - Remove dead code, unused imports
   - Simplify complex conditionals
   - Apply DRY where obvious
   - Use modern syntax
   - **Only simplify if improvements are clear and safe**
   - **Skip if changes are minimal or already clean**
4. **Re-stage**: If simplified, `git add -A` again
5. **Commit**: Generate ONE-LINE message (max 50 chars):
   - `fix: [what was fixed]`
   - `feat: [what was added]`
   - `update: [what was modified]`
   - `refactor: [what was reorganized]`

## Message Rules

- **ONE LINE ONLY** - no body, no details
- **Under 50 characters** - be concise
- **No periods** - waste of space
- **Present tense** - "add" not "added"
- **Lowercase after colon** - `fix: typo` not `fix: Typo`

## Examples

```
feat: add user authentication
fix: resolve memory leak
update: improve error handling
refactor: simplify api routes
docs: update readme
```

## Execution

- NO interactive commands
- NO verbose messages
- NO "Generated with" signatures
- If no changes, exit silently

## Priority

Speed > Detail. Keep commits atomic and history clean.
