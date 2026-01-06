#!/bin/bash

# Script to run lint and typecheck after edits if ESLint and TypeScript are present

# Get the current working directory from Claude Code
CWD=$(pwd)

# Check if package.json exists
if [ ! -f "$CWD/package.json" ]; then
    exit 0
fi

# Check if we're in the .claude directory - skip linting for config directory
if [[ "$CWD" == *"/.claude"* ]] || [[ "$CWD" == *"/.claude" ]]; then
    exit 0
fi

# Additional check: ensure we have node_modules or at least a valid JS/TS project structure
if [ ! -d "$CWD/node_modules" ] && [ ! -f "$CWD/tsconfig.json" ] && [ ! -f "$CWD/jsconfig.json" ]; then
    exit 0
fi

# Check for linters and TypeScript in dependencies
HAS_ESLINT=$(grep -E '"eslint":|"@eslint/|eslint-' "$CWD/package.json" 2>/dev/null)
HAS_BIOME=$(grep -E '"@biomejs/biome":|"biome":' "$CWD/package.json" 2>/dev/null)
HAS_TYPESCRIPT=$(grep -E '"typescript":' "$CWD/package.json" 2>/dev/null)

# Check if any linter or TypeScript is present
if [ -z "$HAS_ESLINT" ] && [ -z "$HAS_BIOME" ] && [ -z "$HAS_TYPESCRIPT" ]; then
    exit 0
fi

# Check if pnpm is available
if ! command -v pnpm &> /dev/null; then
    exit 0
fi

# Check if lint script exists
HAS_LINT_SCRIPT=$(grep -E '"lint":' "$CWD/package.json" 2>/dev/null)
HAS_TYPECHECK_SCRIPT=$(grep -E '"typecheck":' "$CWD/package.json" 2>/dev/null)

# Run lint command based on available linter
if [ ! -z "$HAS_LINT_SCRIPT" ]; then
    if [ ! -z "$HAS_ESLINT" ]; then
        echo "Running pnpm lint (ESLint detected)..."
        cd "$CWD" && pnpm lint
    elif [ ! -z "$HAS_BIOME" ]; then
        echo "Running pnpm lint (Biome detected)..."
        cd "$CWD" && pnpm lint
    fi
fi

# Run typecheck if TypeScript is present
if [ ! -z "$HAS_TYPESCRIPT" ] && [ ! -z "$HAS_TYPECHECK_SCRIPT" ]; then
    echo "Running pnpm typecheck..."
    cd "$CWD" && pnpm typecheck
fi