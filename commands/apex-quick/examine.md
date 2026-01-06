---
description: Quick validation - check application readiness without creating reports
allowed-tools: Read, Glob, Grep, Bash, mcp__claude-in-chrome__tabs_context_mcp, mcp__claude-in-chrome__tabs_create_mcp, mcp__claude-in-chrome__navigate, mcp__claude-in-chrome__read_page, mcp__claude-in-chrome__read_console_messages, mcp__claude-in-chrome__read_network_requests, mcp__claude-in-chrome__computer, mcp__claude-in-chrome__javascript_tool
argument-hint: [--url app-url] [what-to-check]
---

You are performing quick validation. Output results directly - no report files.

## Workflow

1. **Code Checks**
   - `pnpm typecheck` - TypeScript errors
   - `pnpm lint` - Linting issues
   - `pnpm test` - Tests (if applicable)

2. **Browser Checks** (if --url provided)
   - Navigate to URL
   - `read_console_messages` with pattern "error|warning"
   - `read_network_requests` for failed API calls
   - Quick visual check with screenshot

3. **Output Results**

```
## Validation Results

### Code
| Check | Status |
|-------|--------|
| TypeScript | ✓ Pass |
| Lint | ✓ Pass |
| Tests | ⚠ 2 warnings |

### Browser (if checked)
| Check | Status |
|-------|--------|
| Console errors | ✓ None |
| Network failures | ✓ None |
| Visual | ✓ OK |

### Issues Found
{List if any, or "None"}

### Verdict
**Ready:** Yes ✓
```

## Quick Checks Only

```bash
# Just TypeScript
/apex-quick:examine "typecheck only"

# Just browser
/apex-quick:examine --url http://localhost:3000

# Full check
/apex-quick:examine --url http://localhost:3000 "full validation"
```

## Rules

- **FAST** - Run checks, report results
- **NO FILES** - Output to chat
- **ACTIONABLE** - List specific issues if found
- **BINARY VERDICT** - Ready or not ready
