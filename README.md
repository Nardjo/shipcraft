# Shipcraft

> Ship fast, craft well.

Plugin Claude Code avec agents spécialisés et workflows automatisés pour un développement rapide et de qualité.

## Architecture

### Full Mode (`/rpi`)

```
┌─────────────────────────────────────────────────────────────┐
│                      RPI ORCHESTRATOR                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
    ╔══════════════════════╧═══════════════════════╗
    ║          PHASE 1: RESEARCH (parallel)         ║
    ╚══════════════════════╤═══════════════════════╝
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
  │ requirement- │ │   product-   │ │   senior-    │
  │   parser     │ │   manager    │ │  engineer    │
  │  (sonnet)    │ │  (sonnet)    │ │   (opus)     │
  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
         └─────────────────┼─────────────────┘
                           ▼
    ╔══════════════════════╧═══════════════════════╗
    ║           PHASE 2: GO/NO-GO GATE              ║
    ╚══════════════════════╤═══════════════════════╝
                           ▼
                  ┌──────────────┐
                  │  cto-advisor │──── NO-GO ──→ STOP
                  │   (opus)     │
                  └──────┬───────┘
                         │ GO
                         ▼
    ╔════════════════════╧════════════════════════╗
    ║              PHASE 3: PLAN                    ║
    ╚════════════════════╤════════════════════════╝
                         ▼
                  ┌──────────────┐
                  │   planner    │
                  │   (opus)     │
                  └──────┬───────┘
                         ▼
               ┌───────────────────┐
               │  USER APPROVAL ?  │──── NO ──→ REVISE
               └────────┬──────────┘
                        │ YES
                        ▼
    ╔═══════════════════╧════════════════════════╗
    ║            PHASE 4: EXECUTE                  ║
    ╚═══════════════════╤════════════════════════╝
              ┌─────────┴─────────┐
              ▼                   ▼
     ┌──────────────┐   ┌──────────────┐
     │ implementer  │   │  snipper(s)  │
     │  (sonnet)    │   │   (opus)     │
     │  séquentiel  │   │  parallèle   │
     └──────┬───────┘   └──────┬───────┘
             └────────┬────────┘
                      ▼
    ╔═════════════════╧══════════════════════════╗
    ║         PHASE 5: REVIEW                     ║
    ╚═════════════════╤══════════════════════════╝
                      ▼
             ┌──────────────┐
             │code-reviewer │
             │   (opus)     │
             └──────┬───────┘
                    ▼
    ╔═══════════════╧════════════════════════════╗
    ║         PHASE 6: VERIFY                     ║
    ╚═══════════════╤════════════════════════════╝
                    ▼
             ┌──────────────┐
             │   verifier   │
             │   (opus)     │
             └──────┬───────┘
                    ▼
              ✅ COMPLETE
```

### Light Mode (`/rpi --light`)

```
analyser (haiku) → planner (opus) → [USER APPROVAL] → implementer (sonnet) → verifier (opus)
```

| Agent             | Modèle | Rôle                                            |
| ----------------- | ------ | ----------------------------------------------- |
| `requirement-parser` | sonnet | Parse les requirements et explore le codebase |
| `product-manager` | sonnet | Évalue valeur, scope, MVP, acceptance criteria  |
| `senior-engineer` | opus   | Analyse technique profonde (archi, perf, sécu)  |
| `cto-advisor`     | opus   | Synthèse GO/NO-GO avant planning                |
| `code-reviewer`   | opus   | Code review post-implémentation                 |
| `analyser`        | haiku  | Explore le code, identifie patterns et contexte |
| `planner`         | opus   | Crée des plans d'implémentation détaillés       |
| `implementer`     | sonnet | Exécute les plans avec précision                |
| `verifier`        | opus   | Vérifie, teste, valide                          |
| `snipper`         | haiku  | Éditions rapides et ciblées                     |
| `code-simplifier` | -      | Simplifie et refactorise le code automatiquement |

## Commandes

### Workflows

| Commande   | Description                      | Agents                                      |
| ---------- | -------------------------------- | ------------------------------------------- |
| `/rpi`     | Workflow complet avec GO/NO-GO   | 8 agents spécialisés + implémentation       |
| `/rpi --light` | Workflow léger (ancien APEX) | analyser → planner → implementer → verifier |
| `/rpi --ralph` | Implémentation autonome en boucle | Plan → ralph-loop.sh (contexte frais/itération) |
| `/rpi --team` | Exécution parallèle via agent team | TeamCreate → TaskCreate → N implementers parallèles |
| `/rpi --worktree` | Travail isolé dans un git worktree | EnterWorktree → workflow → merge/keep/discard |
| `/debug`   | Diagnostic et fix de bugs        | analyser → snipper → verifier               |
| `/oneshot` | Exécution autonome rapide        | -                                           |

### Git

| Commande                   | Description                            |
| -------------------------- | -------------------------------------- |
| `/git:branch`              | Crée une branche depuis une description |
| `/git:commit-push-pr`      | **Commit + Push + PR + CI check** en une commande |
| `/git:commit`              | Commit rapide + simplification auto    |
| `/git:push`                | Push avec upstream auto                |
| `/git:create-pull-request` | Création PR                            |
| `/git:review-pr`           | Review de PR                           |
| `/git:watch-ci`            | Monitoring CI + auto-fix               |

## Usage

### RPI - Workflow complet

```
/rpi Ajouter l'authentification OAuth
```

→ Research (6 phases) → GO/NO-GO → Plan → **Approbation** → Implémentation → Review → Vérification

### RPI Light - Workflow rapide

```
/rpi --light Ajouter un bouton de logout
```

→ Analyse → Plan → **Approbation** → Implémentation → Vérification

### Debug - Correction de bugs

```
/debug "TypeError dans le composant login"
```

→ Diagnostic → Fix → Vérification

### RPI Ralph — Implémentation autonome

```
/rpi --ralph Refactorer le système d'authentification
```

> Research → Plan → **Approbation** → Ralph Loop (1 step/itération, contexte frais, commit auto) → Rapport final

Chaque itération lance un Claude avec `--print`, implémente UN step du plan, commit, et sort. La boucle s'arrête quand tout est fait. Max 25 itérations par défaut (`--max N` pour changer).

### RPI Team — Exécution parallèle

```
/rpi --team Migrer les composants vers la nouvelle API
```

> Research → Plan → **Approbation** → Team (2-4 implementers en parallèle via TaskCreate) → Review → Vérification

### RPI Worktree — Isolation complète

```
/rpi --worktree Refactorer le module auth
```

> Crée un worktree isolé → workflow complet → propose merge/keep/discard à la fin

Les flags se combinent : `/rpi --worktree --team` ou `/rpi --worktree --ralph`.

### OneShot - Exécution directe

```
/oneshot Corriger le typo dans le header
```

→ Fait. Pas de questions.

## Structure

```
shipcraft/
├── agents/
│   ├── analyser.md
│   ├── planner.md
│   ├── implementer.md
│   ├── verifier.md
│   ├── snipper.md
│   ├── code-simplifier.md
│   ├── requirement-parser.md
│   ├── product-manager.md
│   ├── senior-engineer.md
│   ├── cto-advisor.md
│   └── code-reviewer.md
├── commands/
│   ├── rpi.md
│   ├── debug.md
│   ├── oneshot.md
│   └── git/
├── scripts/
│   └── ralph-loop.sh
├── templates/
│   └── ralph-prompt.md
│       ├── branch.md
│       ├── commit-push-pr.md
│       ├── commit.md
│       ├── push.md
│       ├── create-pull-request.md
│       ├── review-pr.md
│       └── watch-ci.md
└── .claude-plugin/
    └── plugin.json
```

## Installation

```bash
/plugin marketplace add Nardjo/shipcraft
/plugin install shipcraft
```

Ou manuellement : cloner le repo dans votre dossier plugins Claude Code.

```bash
git clone git@github.com:Nardjo/shipcraft.git
```

## Auteur

Jordan Bastin

## Licence

MIT
