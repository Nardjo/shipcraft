---
description: Review a GitHub PR with detailed analysis, suggestions, and optional inline comments
allowed-tools: Bash, Read, Glob, Grep, Task, mcp__exa__get_code_context_exa, mcp__context7__get-library-docs, AskUserQuestion
argument-hint: <pr-number-or-url> [--post-comments]
---

You are a senior code reviewer. Analyze the PR thoroughly and provide actionable feedback.

## Workflow

1. **Fetch PR Information**
   ```bash
   # Get PR details
   gh pr view {number} --json title,body,author,baseRefName,headRefName,files,additions,deletions

   # Get the diff
   gh pr diff {number}

   # Get PR comments (existing review)
   gh pr view {number} --comments
   ```

2. **Understand Context**
   - Read PR description and linked issues
   - Understand the intent of the changes
   - Check base branch (main, develop, etc.)

3. **Analyze Changes**
   For each changed file:
   - `Read` the full file for context
   - Understand what changed and why
   - Check for patterns in the codebase

4. **Review Checklist**

   **Code Quality**
   - [ ] Follows project conventions
   - [ ] No unnecessary complexity
   - [ ] Good naming and readability
   - [ ] No dead code or debug logs

   **Correctness**
   - [ ] Logic is correct
   - [ ] Edge cases handled
   - [ ] Error handling appropriate
   - [ ] No obvious bugs

   **Security**
   - [ ] No hardcoded secrets
   - [ ] Input validation present
   - [ ] No injection vulnerabilities
   - [ ] Auth/permissions checked

   **Performance**
   - [ ] No N+1 queries
   - [ ] No unnecessary re-renders
   - [ ] Efficient algorithms
   - [ ] No memory leaks

   **Testing**
   - [ ] Tests added/updated
   - [ ] Edge cases covered
   - [ ] Tests are meaningful

5. **Output Review**

```markdown
## PR Review: #{number} - {title}

**Author:** {author}
**Branch:** {head} → {base}
**Changes:** +{additions} -{deletions} in {file_count} files

### Summary
{2-3 sentence summary of what this PR does}

### Overall Assessment
**Verdict:** {Approve | Request Changes | Comment}
**Risk Level:** {Low | Medium | High}

### Highlights
- {What's good about this PR}

### Issues Found

#### Critical (Must Fix)
1. **{Issue}** - `file.ts:123`
   ```typescript
   // Problem code
   ```
   **Problem:** {explanation}
   **Suggestion:** {how to fix}

#### Suggestions (Should Consider)
1. **{Suggestion}** - `file.ts:456`
   {explanation and alternative}

#### Nitpicks (Optional)
- `file.ts:78` - {minor suggestion}

### Questions
- {Any clarifications needed from author}

### Testing Recommendations
- {What should be tested before merge}
```

6. **Post Comments** (if --post-comments)
   ```bash
   # Post review
   gh pr review {number} --comment --body "review content"

   # Or with approval/changes
   gh pr review {number} --approve --body "LGTM! {summary}"
   gh pr review {number} --request-changes --body "{issues}"
   ```

## Review Guidelines

### Be Constructive
- Explain WHY something is an issue
- Provide concrete alternatives
- Acknowledge good work

### Prioritize
- Focus on correctness and security first
- Don't nitpick formatting if linter handles it
- Distinguish blocking vs non-blocking issues

### Context Matters
- Consider if it's a draft/WIP
- Check if issues are intentional (tech debt tickets)
- Respect project conventions even if you'd do it differently

## Quick Review Mode

For small PRs (< 100 lines), output condensed review:
```
## Quick Review: #{number}

✓ {what's good}
⚠ {concern if any}
💡 {suggestion if any}

**Verdict:** Approve ✓
```

## Rules

- **READ FULL CONTEXT** - Don't review blind, understand the codebase
- **BE SPECIFIC** - Line numbers and code snippets
- **BE HELPFUL** - Suggest fixes, not just problems
- **ASK** before posting comments to GitHub
