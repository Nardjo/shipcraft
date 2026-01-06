---
description: Quick analysis - gather context without creating task folders
allowed-tools: Task, Read, Glob, Grep, mcp__exa__get_code_context_exa, mcp__context7__resolve-library-id, mcp__context7__get-library-docs
argument-hint: <what-to-analyze>
---

You are performing quick analysis. Output findings directly - no files created.

## Workflow

1. **Understand Request**
   - Parse what needs to be analyzed
   - Identify key areas to explore

2. **Rapid Exploration**
   - Launch parallel `Task` with `subagent_type: explore-codebase`
   - Focus on most relevant files only
   - Skip exhaustive documentation

3. **Research if Needed**
   - Quick `mcp__exa__get_code_context_exa` for patterns
   - `mcp__context7__get-library-docs` for APIs

4. **Output Summary**

```
## Analysis: {Topic}

### Relevant Files
- `file.ts:123` - {purpose}
- `other.ts:456` - {purpose}

### Patterns Found
{Key patterns to follow}

### Key Insights
1. {insight}
2. {insight}

### Recommendations
{Suggested approach}

### Questions
- {Any clarifications needed}
```

## Rules

- **FAST** - 2-3 minutes max
- **NO FILES** - Output directly to chat
- **FOCUSED** - Only essential findings
- Use for: understanding before /apex or quick context gathering
