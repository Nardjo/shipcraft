---
description: Analyze phase - gather all context and create comprehensive analysis report
allowed-tools: Task, Read, Glob, Grep, Write, Bash, mcp__exa__get_code_context_exa, mcp__context7__resolve-library-id, mcp__context7__get-library-docs
argument-hint: [task-name]
---

You are performing deep analysis for a complex task. Your output is a comprehensive analysis.md file that will be used in future conversations.

## Workflow

1. **Load Task Context**
   - If task-name provided: read `.claude/tasks/{task-name}/meta.md`
   - If not: ask user or look for most recent task in `.claude/tasks/`
   - Understand the task description and goals

2. **Deep Exploration**
   - Launch multiple `Task` with `subagent_type: explore-codebase` in parallel:
     - Find all related files and components
     - Discover existing patterns and conventions
     - Locate integration points and dependencies
     - Search for similar implementations
   - Read key files thoroughly

3. **Research**
   - `mcp__exa__get_code_context_exa` for relevant patterns
   - `mcp__context7__get-library-docs` for framework APIs
   - Document any external dependencies

4. **Write analysis.md**

```markdown
# Analysis: {Task Name}

**Analyzed:** {date}
**Status:** complete

## Task Understanding

### Objective
{Clear statement of what needs to be accomplished}

### Requirements
- {Explicit requirement 1}
- {Explicit requirement 2}
- {Inferred requirement}

### Out of Scope
- {What this task does NOT include}

## Codebase Analysis

### Relevant Files
| File | Purpose | Relevance |
|------|---------|-----------|
| `path/file.ts` | {what it does} | {why it matters} |

### Existing Patterns
{Patterns found that should be followed}

```{language}
// Example of pattern from codebase
```

### Architecture Context
{How this fits into the broader architecture}

### Dependencies
- **Internal:** {modules, components}
- **External:** {libraries, APIs}

## Technical Considerations

### Challenges
1. {Challenge 1 and potential approach}
2. {Challenge 2 and potential approach}

### Risks
- {Risk and mitigation}

### Questions Resolved
- Q: {question} → A: {answer from research}

### Open Questions
- {Questions needing user input}

## Recommendations

### Suggested Approach
{High-level approach recommendation}

### Key Decisions Needed
1. {Decision point 1}
2. {Decision point 2}

## References

### Code References
- `file.ts:123` - {description}
- `other.ts:456` - {description}

### Documentation
- {Links to relevant docs}
```

5. **Update meta.md**
   - Mark analysis as complete
   - Add any notes

6. **Output Summary**
   ```
   Analysis complete for "{task-name}"

   Key findings:
   - {finding 1}
   - {finding 2}

   Open questions:
   - {question needing input}

   Next: Run /apex:2-plan to create implementation strategy
   ```

## Rules

- Be EXHAUSTIVE - this file will be the only context in future conversations
- Include actual code snippets, not just descriptions
- Document ALL relevant files with line numbers
- Note patterns explicitly so they can be followed
- Flag any blockers or questions clearly
