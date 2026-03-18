# RPI Ralph Loop — Implementation Iteration

You are inside an autonomous loop. Each iteration you implement ONE step, then exit.

## Instructions

1. Read `.rpi/plan.md` — the approved implementation plan
2. Read `.rpi/progress.md` — what's been done so far
3. Run `git log --oneline -10` — recent commits
4. Identify the NEXT incomplete phase/step
5. Implement ONLY that one step
6. Run verification: typecheck, lint, test (if applicable)
7. Commit changes: `git add -A && git commit -m "rpi: <description>"`
8. Append to `.rpi/progress.md` what you did
9. If ALL steps are complete and verified:
   - Output exactly: <PROMISE>COMPLETE</PROMISE>
10. Exit (do NOT start another step)

## Rules

- ONE step per iteration. Never do multiple steps.
- If blocked on a step, note it in progress.md and move to the next one.
- Match existing code style. Follow the plan exactly.
- Do NOT add features not in the plan.

## Plan

(content of .rpi/plan.md will be injected here by the orchestrator)
