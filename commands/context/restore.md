---
description: Restore session context from a snapshot after /clear
allowed-tools: Bash, Read
arguments: "<snapshot-id> | latest | --list"
---

Load a saved snapshot and present context to continue work.

## Arguments

- `<id>` - Restore specific snapshot
- `latest` - Most recent snapshot
- `--list` - Show available snapshots

## Commands

### List snapshots:
```bash
ls -t ~/.claude-snapshots/*.json 2>/dev/null | head -10 | while read f; do
  id=$(basename "$f" .json)
  goal=$(grep -o '"goal":"[^"]*"' "$f" | cut -d'"' -f4 | head -c 50)
  echo "$id  $goal"
done
```

### Get latest ID:
```bash
ls -t ~/.claude-snapshots/*.json 2>/dev/null | head -1 | xargs basename | sed 's/.json//'
```

### Load snapshot:
```bash
cat ~/.claude-snapshots/[ID].json
```

## Output Format

After loading, present:

```markdown
# Restored: [ID]
**Branch:** [branch] | **Goal:** [goal]

## Current Task
[task]

## Files Modified
- `path`: summary

## Key Decisions
- decision

## Next Steps
1. step

---
Ready to continue.
```

Keep presentation concise - the snapshot data is already minimal.
