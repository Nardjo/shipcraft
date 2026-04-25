# Shipcraft

> Ship fast, craft well.

Plugin Claude Code avec agents spécialisés et workflows automatisés pour un développement rapide et de qualité.

## Architecture

### Light Mode (`/rpi`, défaut)

```
analyser (haiku) → planner (opus) → [USER APPROVAL] → implementer (sonnet) → verifier (sonnet)
```

L'analyser écrit son rapport complet dans `.rpi/context.md` ; les agents en aval lisent ce fichier au lieu de re-explorer.

### Full Mode (`/rpi --full`, opt-in)

```
RESEARCH (parallèle)
  requirement-parser (sonnet) ─→ écrit .rpi/context.md
       │
       ├─→ product-manager (sonnet) ─┐
       └─→ senior-engineer (opus)    ├─→ GO/NO-GO (cto-advisor opus, skipped si consensus GO)
                                     │
                                     ▼
                                  PLAN (planner opus)
                                     │
                          [USER APPROVAL bloquant]
                                     │
                                     ▼
                          EXECUTE (implementer sonnet
                                  ou snipper sonnet ×N)
                                     │
                                     ▼
                          VERIFY (verifier sonnet)
                                  build + review + requirements
                                     │
                                     ▼
                                ✅ COMPLETE
```

Le `verifier` combine désormais build checks, code review et validation des requirements en un seul agent.

| Agent                | Modèle | Rôle                                                   |
| -------------------- | ------ | ------------------------------------------------------ |
| `analyser`           | haiku  | Explore le code, écrit `.rpi/context.md` (light mode)  |
| `requirement-parser` | sonnet | Parse les requirements, écrit `.rpi/context.md` (full) |
| `product-manager`    | sonnet | Évalue valeur, scope, MVP, acceptance criteria         |
| `senior-engineer`    | opus   | Analyse technique profonde (archi, perf, sécu)         |
| `cto-advisor`        | opus   | Synthèse GO/NO-GO (skipped si consensus)               |
| `planner`            | opus   | Crée des plans d'implémentation détaillés              |
| `implementer`        | sonnet | Exécute les plans avec précision                       |
| `snipper`            | sonnet | Éditions rapides et ciblées                            |
| `verifier`           | sonnet | Build checks + code review + requirements validation   |
| `code-simplifier`    | -      | Simplifie et refactorise le code automatiquement       |

## Commandes

### Workflows

| Commande          | Description                        | Agents                                              |
| ----------------- | ---------------------------------- | --------------------------------------------------- |
| `/rpi`            | Workflow léger (défaut)            | analyser → planner → implementer → verifier         |
| `/rpi --full`     | Workflow complet avec GO/NO-GO     | 6 agents + implémentation + verifier fusionné       |
| `/rpi --ralph`    | Implémentation autonome en boucle  | Plan → ralph-loop.sh (contexte frais/itération)     |
| `/rpi --team`     | Exécution parallèle via agent team | TeamCreate → TaskCreate → N implementers parallèles |
| `/rpi --worktree` | Travail isolé dans un git worktree | EnterWorktree → workflow → merge/keep/discard       |
| `/debug`          | Diagnostic et fix de bugs          | analyser → snipper → verifier                       |
| `/oneshot`        | Exécution autonome rapide          | -                                                   |

### Git

| Commande                   | Description                                       |
| -------------------------- | ------------------------------------------------- |
| `/git:branch`              | Crée une branche depuis une description           |
| `/git:cpp`                 | **Commit + Push + PR + CI check** en une commande |
| `/git:commit`              | Commit rapide + simplification auto               |
| `/git:push`                | Push avec upstream auto                           |
| `/git:create-pull-request` | Création PR                                       |
| `/git:review-pr`           | Review de PR                                      |
| `/git:watch-ci`            | Monitoring CI + auto-fix                          |

## Usage

### RPI - Workflow léger (défaut)

```
/rpi Ajouter un bouton de logout
```

→ Analyse → Plan → **Approbation** → Implémentation → Vérification

### RPI Full - Workflow complet

```
/rpi --full Ajouter l'authentification OAuth
```

→ Research (parallèle) → GO/NO-GO (court-circuité si consensus) → Plan → **Approbation** → Implémentation → Vérification (build + review + requirements)

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

Chaque itération lance un Claude avec `--print`, implémente UN step du plan, commit, et sort. La boucle s'arrête quand tout est fait. Max 15 itérations par défaut (`--max N` pour changer).

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
│   ├── verifier.md          # fused: build + code review + requirements
│   ├── snipper.md
│   ├── code-simplifier.md
│   ├── requirement-parser.md
│   ├── product-manager.md
│   ├── senior-engineer.md
│   └── cto-advisor.md
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
