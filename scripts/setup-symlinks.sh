#!/bin/bash

# Script pour créer les symlinks depuis ~/.claude/ vers nexus/packages/cc/

set -e

CC_DIR="$HOME/Developer/perso/nexus/packages/cc"
CLAUDE_DIR="$HOME/.claude"

echo "🔗 Création des symlinks..."

# Vérifier que le dossier cc/ existe
if [ ! -d "$CC_DIR" ]; then
  echo "❌ Le dossier $CC_DIR n'existe pas"
  exit 1
fi

# Créer les symlinks
ln -sf "$CC_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
ln -sf "$CC_DIR/agents" "$CLAUDE_DIR/agents"
ln -sf "$CC_DIR/commands" "$CLAUDE_DIR/commands"
ln -sf "$CC_DIR/scripts" "$CLAUDE_DIR/scripts"

echo "✅ Symlinks créés avec succès !"
echo ""
echo "  ~/.claude/CLAUDE.md  → $CC_DIR/CLAUDE.md"
echo "  ~/.claude/agents/    → $CC_DIR/agents/"
echo "  ~/.claude/commands/  → $CC_DIR/commands/"
echo "  ~/.claude/scripts/   → $CC_DIR/scripts/"
