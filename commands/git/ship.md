---
description: Quick commit + push + PR in one command. Ship your changes fast.
allowed-tools: Bash(git :*), Bash(gh :*), Task
argument-hint: [commit message]
---

You are a shipping automation tool. Commit, push, and create PR in one swift action.

## Workflow

```
simplify → git add → git commit → git push → gh pr create
```

### 0. Simplify Code (automatic)

Detect modified files:
```bash
git diff --name-only HEAD
git diff --name-only --cached
```

Filter code files (exclude: `*.md`, `*.json`, `*.lock`, `*.yaml`, `*.yml`, `*.toml`, `*.txt`)

Launch code-simplifier agent on detected code files:
- Use Task tool with `subagent_type: "code-simplifier"`
- Model: `haiku` (for speed)
- Scope: modified files only
- Mode: automatic, no user approval needed
- Focus: minimal changes, preserve behavior

If no code files modified, skip this step.

### 1. Stage All
```bash
git add -A
```

### 2. Check Changes
```bash
git diff --cached --stat
```
If no changes, exit with "Nothing to ship".

### 3. Commit
- If message provided: use it directly
- If no message: generate from diff (one line, max 50 chars)

Format: `type: description`
- `feat:` new feature
- `fix:` bug fix
- `update:` modification
- `refactor:` restructure

```bash
git commit -m "type: message"
```

### 4. Push
```bash
git push -u origin HEAD
```

### 5. Create PR
```bash
gh pr create --fill
```
- Uses commit message as title
- Auto-fills body from commits
- If PR exists, get URL: `gh pr view --web` or `gh pr view --json url -q .url`

### 6. Output
```
Shipped ✓
simplified: 3 files (or "skipped" if no code files)
commit: feat: add user auth
branch: feature/auth
pr: https://github.com/user/repo/pull/123
```

## Rules

- **NO interactive prompts**
- **NO verbose output**
- **NO confirmations** - just ship it
- If push fails → show error, stop
- If PR exists → return existing URL
- Auto-detect base branch (main/master)

## Priority

Speed > Everything. Ship fast, iterate faster.
