#!/bin/bash

# Script pour supprimer les symlinks de ~/.claude/

set -e

CLAUDE_DIR="$HOME/.claude"

echo "🗑️  Suppression des symlinks..."

# Supprimer les symlinks s'ils existent
[ -L "$CLAUDE_DIR/CLAUDE.md" ] && rm "$CLAUDE_DIR/CLAUDE.md" && echo "  ✓ Supprimé: CLAUDE.md"
[ -L "$CLAUDE_DIR/agents" ] && rm "$CLAUDE_DIR/agents" && echo "  ✓ Supprimé: agents/"
[ -L "$CLAUDE_DIR/commands" ] && rm "$CLAUDE_DIR/commands" && echo "  ✓ Supprimé: commands/"
[ -L "$CLAUDE_DIR/scripts" ] && rm "$CLAUDE_DIR/scripts" && echo "  ✓ Supprimé: scripts/"

echo ""
echo "✅ Symlinks supprimés !"
