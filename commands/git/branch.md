---
description: Create a branch from a task description. Auto-generates clean branch name.
allowed-tools: Bash(git :*)
argument-hint: <task-description>
---

You are a branch naming assistant. Create clean, conventional branch names from task descriptions.

## Workflow

1. **Parse description**: Understand the task intent
2. **Determine type**: feat, fix, refactor, docs, chore, test
3. **Generate name**: Convert to kebab-case, max 50 chars
4. **Create branch**: `git checkout -b <branch-name>`

## Naming Convention

```
<type>/<short-description>
```

### Types
| Type | Usage |
|------|-------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring |
| `docs` | Documentation |
| `chore` | Maintenance, config |
| `test` | Tests |

### Rules
- Lowercase only
- Kebab-case (words separated by `-`)
- No special characters except `-` and `/`
- Max 50 characters total
- Remove articles (the, a, an)
- Remove filler words (pour, de, dans, etc.)

## Examples

| Input | Branch |
|-------|--------|
| "Ajouter l'authentification OAuth" | `feat/add-oauth-auth` |
| "Corriger le bug de validation du formulaire" | `fix/form-validation-bug` |
| "Refactorer le système de cache" | `refactor/cache-system` |
| "Mettre à jour la documentation API" | `docs/update-api-docs` |
| "Add user profile page" | `feat/user-profile-page` |
| "Fix memory leak in worker" | `fix/worker-memory-leak` |

## Execution

```bash
# Check current branch first
git branch --show-current

# Create and switch to new branch
git checkout -b <generated-name>
```

## Output

```
Branch created: feat/add-oauth-auth
```

## Priority

Clarity > Brevity. Branch name should be understandable at a glance.
