---
description: Export session context (compact format, ~5k tokens)
allowed-tools: Bash, Write
arguments: "[output_path] - Optional file path"
---

Export session context in a **compact format** optimized for token efficiency.

## Format

Generate this structure (keep each field SHORT):

```markdown
# Context [YYYY-MM-DD]

## Goal
[1-2 sentences: what user wanted]

## Done
- `file.ext`: [what changed]
- `other.ext`: [what changed]

## Decisions
- [key decision and why]

## Issues
- [problem → solution] (only if relevant)

## Next
- [ ] [remaining task]

## Notes
[Any critical context needed to continue - be selective]
```

## Rules

1. **Brevity > completeness**: Only include what's needed to continue the work
2. **No redundancy**: Don't repeat information across sections
3. **Skip empty sections**: If no issues, omit "Issues"
4. **Files**: Only list files actually modified, not just read
5. **Notes**: Max 3-4 sentences of truly essential context

## Export

Count lines. If < 100: clipboard. Else: file.

```bash
# Clipboard (macOS)
cat > /tmp/ctx.md << 'EOF'
[CONTENT]
EOF
pbcopy < /tmp/ctx.md && echo "Copied ($(wc -l < /tmp/ctx.md) lines)"
```

Or use Write tool for file: `context-YYYYMMDD-HHMM.md`

## Target

Aim for **~100-150 lines** of markdown, which translates to ~3-5k tokens when reimported.
