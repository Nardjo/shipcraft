---
description: Export complete session context to clipboard or file
allowed-tools: Bash, Write
arguments: "[output_path] - Optional custom output path for file export"
---

You are a session export tool. Capture the COMPLETE context of this Claude Code session and export a comprehensive markdown summary.

## Workflow

1. **SYNTHESIZE** - Gather all session information:
   - Initial goal/task and user request
   - All key decisions made during session
   - Every file read, modified, or created
   - Implementation details and code changes
   - Problems encountered and how they were solved
   - Full context of discussions and reasoning
   - Next steps or remaining work

2. **FORMAT** - Create exhaustive markdown document:

```markdown
# Session Export - [YYYY-MM-DD HH:MM]

## Goal

[What was the main objective? What did the user ask for?]

## Decisions

[Every decision made, no matter how small:
- Why this approach over alternatives?
- What trade-offs were considered?
- What assumptions were made?]

## Files Modified

[For each file changed:]
### `path/to/file.ext`
- **Action**: [Created/Modified/Deleted]
- **Changes**: [Detailed description of what changed]
- **Reason**: [Why this change was necessary]

## Implementation Details

[Deep dive into what was implemented:
- Code patterns used
- Architecture decisions
- Dependencies added/changed
- Configuration updates]

## Problems Encountered

[Every issue, blocker, or challenge:
- What went wrong?
- Error messages or unexpected behavior
- How it was resolved
- What was learned]

## Context & Reasoning

[The full story:
- Background information used
- Codebase patterns followed
- Why certain choices were made
- Relevant conversation highlights]

## Next Steps

[What remains to be done:
- Incomplete tasks
- Future improvements
- Testing needed
- Documentation to update]

## Commands Executed

[List of all bash commands run with their purpose]

## Session Metadata

- **Date**: [timestamp]
- **Files changed**: [use `git diff --stat` or count from session]
- **Commands run**: [count from session]
```

3. **SIZE CHECK** - Count lines of generated content

4. **EXPORT** - Based on size and arguments:
   - If custom path provided as argument → write to that path
   - **< 200 lines**: Copy to clipboard (cross-platform detection)
   - **>= 200 lines**: Write to `session-export-YYYY-MM-DD-HHMM.md` in project root

## Export Rules

### Exhaustivity over Concision
- Capture EVERYTHING - no detail is too small
- Include all context, even if it seems obvious
- Better to over-document than under-document
- This is a memory artifact, not a polished doc

### What to Include
- All file paths (absolute when possible)
- All code snippets changed (before/after when relevant)
- All error messages encountered
- All discussion points and user questions
- All reasoning and thought process
- Timestamps for major milestones

### What NOT to Skip
- Failed attempts and dead ends (valuable learning)
- Alternative approaches considered
- Assumptions made along the way
- Context from previous parts of conversation
- Tool calls and their results

## Execution

### For clipboard (< 200 lines):

Write content to temp file then pipe to clipboard:

```bash
# Write the export content to a temp file
cat > /tmp/session-export.md << 'EXPORT_END'
[FULL MARKDOWN CONTENT HERE]
EXPORT_END

# Copy to clipboard (cross-platform)
if [[ "$OSTYPE" == "darwin"* ]]; then
  cat /tmp/session-export.md | pbcopy && echo "✓ Copied to clipboard ($(wc -l < /tmp/session-export.md) lines)"
elif command -v xclip &> /dev/null; then
  cat /tmp/session-export.md | xclip -selection clipboard && echo "✓ Copied to clipboard"
elif command -v wl-copy &> /dev/null; then
  cat /tmp/session-export.md | wl-copy && echo "✓ Copied to clipboard"
elif grep -qi microsoft /proc/version 2>/dev/null; then
  cat /tmp/session-export.md | clip.exe && echo "✓ Copied to clipboard"
else
  echo "No clipboard available, use file export instead"
fi
```

**IMPORTANT**: Replace `[FULL MARKDOWN CONTENT HERE]` with the actual generated markdown. Use `EXPORT_END` as delimiter (unlikely to appear in content).

### For file (>= 200 lines):

Use Write tool to create:
- File: `session-export-YYYY-MM-DD-HHMM.md`
- Location: Project root (working directory), or custom path if provided as argument
- Content: Full markdown export

Then confirm:
```bash
echo "✓ Session exported to session-export-YYYY-MM-DD-HHMM.md (X lines)"
```

## Output Confirmation

After export, provide brief summary:
```
Session exported successfully!

Summary:
- Files modified: X
- Problems solved: X
- Lines exported: X
- Output: [clipboard/file]

The export captures the complete context of this session.
```

## Priority

Completeness > Brevity. Lose no context. Every detail matters for future reference.
