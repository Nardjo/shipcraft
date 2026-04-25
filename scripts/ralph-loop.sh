#!/bin/bash
# Ralph Loop — Autonomous implementation with fresh context per iteration
# Usage: ralph-loop.sh [--max N] [--model MODEL]
# Runs from the project root where .rpi/ exists

set -e
MAX_ITER=15
MODEL=""
PROMISE="<PROMISE>COMPLETE</PROMISE>"
RPI_DIR=".rpi"

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --max) MAX_ITER="$2"; shift 2 ;;
    --model) MODEL="--model $2"; shift 2 ;;
    *) shift ;;
  esac
done

# Validate
[ -f "$RPI_DIR/plan.md" ] || { echo "❌ No .rpi/plan.md found"; exit 1; }
[ -f "$RPI_DIR/ralph-prompt.md" ] || { echo "❌ No ralph-prompt.md found"; exit 1; }

# Init progress file
[ -f "$RPI_DIR/progress.md" ] || echo "# Ralph Progress Log" > "$RPI_DIR/progress.md"

for i in $(seq 1 $MAX_ITER); do
  echo "🔄 Iteration $i/$MAX_ITER"

  output=$(claude $MODEL --print < "$RPI_DIR/ralph-prompt.md" 2>&1)

  if echo "$output" | grep -q "$PROMISE"; then
    echo "✅ Complete after $i iterations"
    # Notify
    [ -f ~/.claude/scripts/notify.sh ] && \
      echo '{"notification_type":"complete","message":"Ralph loop done"}' | bash ~/.claude/scripts/notify.sh
    exit 0
  fi

  echo "--- Iteration $i ---" >> "$RPI_DIR/progress.md"
  echo "$output" | tail -30 >> "$RPI_DIR/progress.md"
  echo "" >> "$RPI_DIR/progress.md"
done

echo "⚠️ Max iterations ($MAX_ITER) reached"
exit 1
