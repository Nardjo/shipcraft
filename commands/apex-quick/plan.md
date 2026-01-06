---
description: Quick planning - create implementation strategy without saving to files
allowed-tools: Task, Read, Glob, Grep, AskUserQuestion, mcp__exa__get_code_context_exa
argument-hint: <what-to-plan>
---

You are creating a quick implementation plan. Output directly - no files created.

## Workflow

1. **Understand Task**
   - Parse requirements
   - Quick exploration if needed (use explore-codebase agent)

2. **Ask Clarifications** (if critical ambiguity)
   - Use `AskUserQuestion` for blocking questions only
   - Make reasonable assumptions otherwise

3. **Output Plan**

```
## Plan: {Task}

### Approach
{Chosen strategy in 2-3 sentences}

### Steps
1. **{Step name}**
   - File: `path/file.ts`
   - Action: {what to do}

2. **{Step name}**
   - File: `path/other.ts`
   - Action: {what to do}

...

### Files Summary
| File | Action |
|------|--------|
| `x.ts` | Create |
| `y.ts` | Modify |

### Verification
- {How to verify it works}

Ready to execute? Run /apex-quick:execute or /oneshot
```

## Rules

- **CONCISE** - No lengthy explanations
- **ACTIONABLE** - Steps must be clear enough to execute
- **NO FILES** - Output to chat only
- **FAST** - Plan in under 2 minutes
- Use for: quick planning before /oneshot or understanding scope
