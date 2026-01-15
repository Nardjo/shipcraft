---
description: Save session context snapshot for later restoration after /clear
allowed-tools: Bash, Write
---

Save current session context to `~/.claude-snapshots/` for restoration.

## Steps

1. **Generate ID**: `SNAPSHOT_ID="$(date +%Y%m%d-%H%M)-$(head -c 3 /dev/urandom | xxd -p)"`

2. **Gather context** (from session memory):
   - Goal: main user objective
   - Task: current work in progress
   - Files: modified files with brief summary
   - Decisions: key choices made
   - Next: remaining work

3. **Save snapshot**:

```bash
mkdir -p ~/.claude-snapshots
SNAPSHOT_ID="$(date +%Y%m%d-%H%M)-$(head -c 3 /dev/urandom | xxd -p)"
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")

cat > ~/.claude-snapshots/${SNAPSHOT_ID}.json << 'EOF'
{
  "id": "[ID]",
  "ts": "[ISO_TIMESTAMP]",
  "pwd": "[CWD]",
  "branch": "[BRANCH]",
  "goal": "[GOAL]",
  "task": "[CURRENT_TASK]",
  "files": ["path:action:summary", ...],
  "decisions": ["decision1", ...],
  "next": ["step1", ...]
}
EOF

echo "Snapshot saved: $SNAPSHOT_ID"
echo "Restore: /restore $SNAPSHOT_ID"
```

Replace placeholders with actual session data. Keep values concise.
