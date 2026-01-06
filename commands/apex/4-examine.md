---
description: Examine phase - validate and test implementation for deployment readiness
allowed-tools: Task, Read, Write, Glob, Grep, Bash, mcp__claude-in-chrome__tabs_context_mcp, mcp__claude-in-chrome__tabs_create_mcp, mcp__claude-in-chrome__navigate, mcp__claude-in-chrome__read_page, mcp__claude-in-chrome__read_console_messages, mcp__claude-in-chrome__read_network_requests, mcp__claude-in-chrome__computer, mcp__claude-in-chrome__javascript_tool
argument-hint: [task-name] [--url app-url]
---

You are validating the implementation. Thoroughly test everything and create a comprehensive examine.md report.

## Workflow

1. **Load Context**
   - Read `.claude/tasks/{task-name}/meta.md`
   - Read `.claude/tasks/{task-name}/plan.md` for expected outcomes
   - Read `.claude/tasks/{task-name}/analysis.md` for requirements

2. **Code Validation**
   - Run type checking: `pnpm typecheck`
   - Run linter: `pnpm lint`
   - Run tests: `pnpm test` (if applicable)
   - Check for console errors/warnings in code

3. **Functional Validation**
   - Verify each requirement from analysis.md
   - Test each feature described in plan.md
   - Check edge cases

4. **Browser Validation** (if --url or UI feature)
   - Navigate to app URL
   - Check console for errors: `read_console_messages`
   - Check network for failed requests: `read_network_requests`
   - Take screenshots of key states
   - Verify UI matches expected behavior

5. **Write examine.md**

```markdown
# Examination Report: {Task Name}

**Examined:** {date}
**Status:** {passed|failed|partial}

## Summary

| Check | Status | Notes |
|-------|--------|-------|
| TypeScript | {pass|fail} | {details} |
| Lint | {pass|fail} | {details} |
| Tests | {pass|fail|n/a} | {details} |
| Functional | {pass|fail} | {details} |
| UI/Browser | {pass|fail|n/a} | {details} |

## Detailed Results

### Code Quality

#### TypeScript
```
{typecheck output or summary}
```
**Issues:** {list of issues if any}

#### Linter
```
{lint output or summary}
```
**Issues:** {list of issues if any}

### Test Results
```
{test output or summary}
```
**Coverage:** {if available}

### Functional Verification

| Requirement | Status | Evidence |
|-------------|--------|----------|
| {req from analysis} | {pass|fail} | {how verified} |

### Browser Inspection

#### Console
- Errors: {count}
- Warnings: {count}
- Details: {list if any}

#### Network
- Failed requests: {count}
- Details: {list if any}

#### Visual
{Screenshot references if taken}

## Issues Found

### Critical (Must Fix)
1. **{Issue title}**
   - Location: `file.ts:123`
   - Description: {what's wrong}
   - Suggested fix: {how to fix}

### Minor (Should Fix)
1. **{Issue title}**
   - {details}

### Improvements (Optional)
1. **{Suggestion}**
   - {details}

## Checklist Verification

From plan.md:
- [x] {completed item}
- [x] {completed item}
- [ ] {incomplete item} - {reason}

## Conclusion

**Deployment Ready:** {Yes|No|With conditions}

**Required Actions:**
1. {action if any}

**Recommendations:**
- {recommendation}

## Sign-off

{Final assessment of the implementation quality and completeness}
```

6. **Update meta.md**
   - Mark examine as complete
   - Update overall task status

7. **Output Summary**
   ```
   Examination complete for "{task-name}"

   Status: {PASSED|FAILED|PARTIAL}

   Critical issues: {count}
   Minor issues: {count}

   {Next steps based on status}
   ```

## Rules

- Be THOROUGH - check everything in the plan
- Be OBJECTIVE - report actual status, not optimistic
- DOCUMENT evidence for each check
- PRIORITIZE issues clearly (critical vs minor)
- Include ACTIONABLE fixes for issues found
