---
description: Save session context checkpoint for later restoration after /clear
allowed-tools: Bash, Write
---

You are a session checkpoint tool. Capture the current session context and save it for restoration after a `/clear`.

## Workflow

1. **SYNTHESIZE** - Gather session context:
   - What was the user's main goal?
   - What task is currently in progress?
   - Key decisions made during session
   - Files read, modified, or created
   - Problems encountered and solutions
   - Next steps or remaining work

2. **GENERATE ID** - Create unique checkpoint identifier:
   ```bash
   CHECKPOINT_ID="$(date +%Y-%m-%d-%H%M)-$(head -c 4 /dev/urandom | xxd -p)"
   echo "$CHECKPOINT_ID"
   ```

3. **CREATE CHECKPOINT** - Build JSON structure and save:

```bash
# Ensure directory exists
mkdir -p ~/.claude-checkpoints

# Get git info
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
PROJECT_PATH=$(pwd)

# Write checkpoint file
cat > ~/.claude-checkpoints/checkpoint-${CHECKPOINT_ID}.json << 'CHECKPOINT_EOF'
{
  "id": "[CHECKPOINT_ID]",
  "timestamp": "[ISO_TIMESTAMP]",
  "project": "[PROJECT_PATH]",
  "git_branch": "[GIT_BRANCH]",
  "goal": "[MAIN_GOAL - What the user wanted to accomplish]",
  "current_task": "[CURRENT_TASK - What was being worked on]",
  "decisions": [
    "[DECISION_1]",
    "[DECISION_2]"
  ],
  "files_modified": [
    {"path": "[FILE_PATH]", "action": "[created/modified/deleted]", "summary": "[WHAT_CHANGED]"}
  ],
  "problems_solved": [
    "[PROBLEM_1 and how it was solved]"
  ],
  "next_steps": [
    "[NEXT_STEP_1]",
    "[NEXT_STEP_2]"
  ],
  "context_summary": "[FREE_FORM_SUMMARY - Complete narrative of the session state, enough to fully understand context]"
}
CHECKPOINT_EOF

echo "✓ Checkpoint saved: ${CHECKPOINT_ID}"
```

4. **UPDATE INDEX** - Add to checkpoint index:

```bash
INDEX_FILE=~/.claude-checkpoints/index.json

# Create index if doesn't exist
if [ ! -f "$INDEX_FILE" ]; then
  echo '{"checkpoints":[]}' > "$INDEX_FILE"
fi

# Add new entry to index (using jq if available, otherwise manual)
if command -v jq &> /dev/null; then
  jq --arg id "$CHECKPOINT_ID" \
     --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     --arg project "$PROJECT_PATH" \
     --arg goal "[MAIN_GOAL_SHORT]" \
     '.checkpoints = [{"id": $id, "timestamp": $ts, "project": $project, "goal": $goal}] + .checkpoints' \
     "$INDEX_FILE" > "${INDEX_FILE}.tmp" && mv "${INDEX_FILE}.tmp" "$INDEX_FILE"
else
  # Fallback: just note the checkpoint was saved
  echo "Note: Install jq for better index management"
fi
```

## JSON Schema

Replace placeholders with actual session data:

| Placeholder | Description |
|-------------|-------------|
| `[CHECKPOINT_ID]` | Generated ID from step 2 |
| `[ISO_TIMESTAMP]` | Current UTC timestamp |
| `[PROJECT_PATH]` | Current working directory |
| `[GIT_BRANCH]` | Current git branch |
| `[MAIN_GOAL]` | User's primary objective this session |
| `[CURRENT_TASK]` | What was actively being worked on |
| `[DECISION_N]` | Each significant decision made |
| `[FILE_PATH]` | Path of each modified file |
| `[NEXT_STEP_N]` | Remaining work items |
| `[FREE_FORM_SUMMARY]` | Complete context narrative |

## Rules

- **Be exhaustive** - Capture everything needed to restore context
- **Be specific** - Include file paths, function names, exact changes
- **Include reasoning** - Why decisions were made, not just what
- **Capture state** - Where things stand right now, not just history

## Output

After saving, confirm:
```
✓ Checkpoint saved: [CHECKPOINT_ID]

To restore after /clear:
  /restore [CHECKPOINT_ID]
  or
  /restore latest
```
