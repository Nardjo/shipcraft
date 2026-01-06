---
description: Planning phase - create detailed implementation strategy from analysis
allowed-tools: Read, Write, Glob, AskUserQuestion, mcp__exa__get_code_context_exa
argument-hint: [task-name]
---

You are creating a detailed implementation plan based on the analysis. Your output is plan.md that will guide execution.

## Workflow

1. **Load Context**
   - Read `.claude/tasks/{task-name}/meta.md`
   - Read `.claude/tasks/{task-name}/analysis.md` thoroughly
   - This is your PRIMARY context - the analysis contains everything

2. **Address Open Questions**
   - If analysis has open questions, use `AskUserQuestion` to resolve them
   - Document answers in the plan

3. **Design Implementation**
   - Based on analysis, design the complete solution
   - Consider all technical constraints identified
   - Follow patterns documented in analysis

4. **Write plan.md**

```markdown
# Implementation Plan: {Task Name}

**Planned:** {date}
**Based on:** analysis.md
**Status:** ready

## Solution Overview

### Approach
{Chosen approach and rationale}

### Architecture
{How the solution fits into existing architecture}

```
{ASCII diagram if helpful}
```

## Implementation Steps

### Phase 1: {Phase Name}
**Goal:** {What this phase achieves}

#### Step 1.1: {Step Name}
- **File:** `path/to/file.ts`
- **Action:** {create|modify|delete}
- **Changes:**
  - {Specific change 1}
  - {Specific change 2}
- **Dependencies:** {what must be done first}

#### Step 1.2: {Step Name}
...

### Phase 2: {Phase Name}
...

## Files to Modify

| File | Action | Description |
|------|--------|-------------|
| `path/new.ts` | Create | {purpose} |
| `path/existing.ts` | Modify | {what changes} |

## Files to Create

### `path/to/new-file.ts`
```typescript
// Skeleton/interface of what this file will contain
interface NewComponent {
  // ...
}
```

## Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| {decision point} | {choice made} | {why} |

## Testing Strategy

### Unit Tests
- {What to test}

### Integration Tests
- {What to test}

### Manual Verification
- {Steps to verify}

## Rollback Plan

{How to undo if something goes wrong}

## Estimated Scope

- **Files:** {count}
- **Complexity:** {low|medium|high}
- **Risk areas:** {list}

## Checklist

- [ ] Step 1.1: {description}
- [ ] Step 1.2: {description}
- [ ] Step 2.1: {description}
...
```

5. **Update meta.md**
   - Mark planning as complete

6. **Output Summary**
   ```
   Plan complete for "{task-name}"

   Scope: {X} files, {Y} steps

   Key phases:
   1. {phase 1}
   2. {phase 2}

   Next:
   - Run /apex:5-tasks to break into subtasks (recommended for large plans)
   - Or run /apex:3-execute to start implementation
   ```

## Rules

- Plan must be ACTIONABLE - someone reading only plan.md should know exactly what to do
- Include code skeletons for new files
- Every step must have clear acceptance criteria
- Reference analysis.md findings explicitly
- Don't add scope beyond what's in analysis
