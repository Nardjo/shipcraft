---
description: Restore session context from a checkpoint after /clear
allowed-tools: Bash, Read
arguments: "<checkpoint-id> | latest | --list"
---

You are a session restore tool. Load a previously saved checkpoint and present the context so work can continue seamlessly.

## Arguments

- `<checkpoint-id>` - Restore specific checkpoint (e.g., `2026-01-14-1130-abc123`)
- `latest` - Restore the most recent checkpoint
- `--list` - Show available checkpoints without restoring

## Workflow

### If `--list`:

```bash
INDEX_FILE=~/.claude-checkpoints/index.json

if [ -f "$INDEX_FILE" ]; then
  echo "Available checkpoints:"
  echo ""
  if command -v jq &> /dev/null; then
    jq -r '.checkpoints[] | "  \(.id)  \(.timestamp)  \(.goal)"' "$INDEX_FILE" | head -20
  else
    cat "$INDEX_FILE"
  fi
else
  echo "No checkpoints found. Use /checkpoint to create one."
fi
```

Then STOP - don't restore anything.

### If `latest`:

```bash
INDEX_FILE=~/.claude-checkpoints/index.json

if [ -f "$INDEX_FILE" ] && command -v jq &> /dev/null; then
  CHECKPOINT_ID=$(jq -r '.checkpoints[0].id' "$INDEX_FILE")
  echo "Latest checkpoint: $CHECKPOINT_ID"
else
  # Fallback: find most recent file
  CHECKPOINT_ID=$(ls -t ~/.claude-checkpoints/checkpoint-*.json 2>/dev/null | head -1 | sed 's/.*checkpoint-//' | sed 's/.json//')
  echo "Latest checkpoint: $CHECKPOINT_ID"
fi
```

Then proceed with that ID.

### Restore checkpoint:

1. **LOAD** - Read the checkpoint file:

```bash
CHECKPOINT_FILE=~/.claude-checkpoints/checkpoint-[CHECKPOINT_ID].json

if [ -f "$CHECKPOINT_FILE" ]; then
  cat "$CHECKPOINT_FILE"
else
  echo "Checkpoint not found: [CHECKPOINT_ID]"
  echo "Use '/restore --list' to see available checkpoints"
  exit 1
fi
```

2. **PARSE** - Extract and understand the JSON content

3. **PRESENT** - Display restored context in clear format:

```markdown
# Session Restored

## Previous Goal
[goal from checkpoint]

## Where We Left Off
[current_task from checkpoint]

## Key Decisions Made
[decisions array, formatted as list]

## Files That Were Modified
[files_modified array with paths and summaries]

## Problems Already Solved
[problems_solved array]

## Next Steps (from previous session)
[next_steps array]

## Full Context
[context_summary - the complete narrative]

---

**Ready to continue.** The above context has been restored from checkpoint `[id]`.
```

## Presentation Rules

- **Make it scannable** - Use headers and bullets
- **Highlight current task** - This is the most important info
- **Include all context** - Don't summarize, present everything
- **End with readiness** - Confirm restoration is complete

## Output Format

```markdown
# Session Restored from [CHECKPOINT_ID]
**Saved:** [timestamp]
**Project:** [project path]
**Branch:** [git_branch]

---

## Goal
[goal]

## Current Task (where we left off)
[current_task]

## Decisions Made
- [decision 1]
- [decision 2]

## Files Modified
- `[path]` - [summary]

## Problems Solved
- [problem and solution]

## Next Steps
1. [step 1]
2. [step 2]

## Context Summary
[full context_summary]

---

✓ Context restored. Ready to continue where you left off.
```

## Error Handling

- **No checkpoints exist**: "No checkpoints found. Use /checkpoint to create one before /clear."
- **Invalid ID**: "Checkpoint '[id]' not found. Use '/restore --list' to see available checkpoints."
- **Corrupted JSON**: "Checkpoint file is corrupted. Showing raw content: [content]"
