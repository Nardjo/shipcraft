---
description: Quick execution - implement changes directly without task folder structure
allowed-tools: Task, Read, Write, Edit, Glob, Grep, Bash, TodoWrite, mcp__exa__get_code_context_exa, mcp__context7__get-library-docs
argument-hint: <what-to-implement>
---

You are executing a task quickly. No persistent files - just implement.

## Workflow

1. **Understand Task**
   - Parse what needs to be done
   - If following a plan from chat, extract steps

2. **Quick Context** (if needed)
   - Fast `Grep`/`Glob` to locate files
   - `Read` only essential files
   - Skip if location is clear

3. **Track with Todos**
   - Use `TodoWrite` for visibility
   - Keep it simple - main steps only

4. **Execute**
   - Implement changes directly
   - Follow existing patterns
   - Fix errors as you go

5. **Verify**
   - Run `pnpm typecheck` / `pnpm lint`
   - Fix any issues

6. **Changelog**
   - Update `CHANGELOG.md` at project root (create if missing)
   - Format:
   ```markdown
   ## [YYYY-MM-DD]

   ### {Type}: {Brief description}

   **Files changed:**
   - `path/to/file.ts` - {what changed}

   **Summary:** {1-2 sentence explanation}

   ---
   ```

7. **Report**
```
## Done

### Changes Made
- `file.ts` - {what changed}
- `other.ts` - {what changed}

### Verification
- TypeScript: ✓
- Lint: ✓

### Notes
{Any relevant info}
```

## Rules

- **NO PLANNING PHASE** - Jump straight to implementation
- **NO PERSISTENT FILES** - Everything in chat
- **MINIMAL QUESTIONS** - Decide and act
- **FAST FEEDBACK** - Report progress inline
- Similar to /oneshot but with more structure
