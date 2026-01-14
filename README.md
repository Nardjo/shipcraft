# Shipcraft

> Ship fast, craft well.

Plugin Claude Code avec agents spécialisés et workflows automatisés pour un développement rapide et de qualité.

## Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  analyser   │───▶│   planner   │───▶│ implementer │───▶│  verifier   │
│   (haiku)   │    │   (opus)    │    │  (sonnet)   │    │   (opus)    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                                                        │
       └──────────────────┐    ┌────────────────────────────────┘
                          ▼    ▼
                    ┌─────────────┐
                    │   snipper   │
                    │   (haiku)   │
                    └─────────────┘
```

| Agent             | Modèle | Rôle                                            |
| ----------------- | ------ | ----------------------------------------------- |
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
| `/apex`    | Workflow complet avec validation | analyser → planner → implementer → verifier |
| `/debug`   | Diagnostic et fix de bugs        | analyser → snipper → verifier               |
| `/oneshot` | Exécution autonome rapide        | -                                           |
| `/export`  | Export session context complète  | -                                           |

### Git

| Commande                   | Description                            |
| -------------------------- | -------------------------------------- |
| `/git:branch`              | Crée une branche depuis une description |
| `/git:ship`                | **Commit + Push + PR** en une commande |
| `/git:commit`              | Commit rapide + simplification auto    |
| `/git:push`                | Push avec upstream auto                |
| `/git:create-pull-request` | Création PR                            |
| `/git:review-pr`           | Review de PR                           |
| `/git:watch-ci`            | Monitoring CI + auto-fix               |

## Usage

### APEX - Workflow méthodique

```
/apex Ajouter l'authentification OAuth
```

→ Analyse → Plan → **Approbation** → Implémentation → Vérification

### Debug - Correction de bugs

```
/debug "TypeError dans le composant login"
```

→ Diagnostic → Fix → Vérification

### Branch - Créer une branche

```
/git:branch Ajouter l'authentification OAuth
```

→ Crée `feat/add-oauth-auth`

### Ship - Livraison express

```
/git:ship "feat: add OAuth"
```

→ Commit → Push → PR créée

### OneShot - Exécution directe

```
/oneshot Corriger le typo dans le header
```

→ Fait. Pas de questions.

### Export - Capture de session

```
/export
```

→ Export complet de la session (clipboard ou fichier si > 200 lignes)

## Structure

```
shipcraft/
├── agents/
│   ├── analyser.md
│   ├── planner.md
│   ├── implementer.md
│   ├── verifier.md
│   ├── snipper.md
│   └── code-simplifier.md
├── commands/
│   ├── apex.md
│   ├── debug.md
│   ├── oneshot.md
│   ├── export.md
│   └── git/
│       ├── branch.md
│       ├── ship.md
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
