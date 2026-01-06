# CC Workflow Plugin

Plugin Claude Code personnel contenant une collection complète d'agents, commandes et scripts pour optimiser le développement.

## Description

Ce plugin regroupe plusieurs workflows et outils d'automatisation pour Claude Code :

- **APEX** : Workflow méthodique Analyse-Plan-Execute-Examine pour les tâches complexes
- **OneShot** : Exécution autonome pour les tâches simples
- **Git automation** : Commandes automatisées pour commit, push, PR et CI monitoring
- **Agents spécialisés** : Copywriter, security expert, SEO performance, etc.
- **Scripts utilitaires** : Validation, linting, hooks personnalisés

## Structure

```
cc-workflow/
├── .claude-plugin/
│   └── plugin.json           # Manifest du plugin
├── agents/                   # Agents spécialisés
│   ├── copywriter.md
│   ├── deep-research.md
│   ├── explore-codebase.md
│   ├── security-expert.md
│   ├── seo-performance.md
│   └── snipper.md
├── commands/                 # Commandes slash
│   ├── apex/                # Workflow APEX en phases
│   ├── apex-quick/          # APEX rapide
│   ├── git/                 # Automation Git
│   ├── sales-page/          # Génération sales pages
│   ├── apex.md              # Workflow APEX complet
│   ├── cleanup-context.md
│   ├── copywriter.md
│   ├── create-skill.md
│   ├── debug.md
│   ├── deep-code-analysis.md
│   └── oneshot.md
└── scripts/                  # Scripts utilitaires
    ├── commit.sh
    ├── create-worktree.sh
    ├── delete-worktree.sh
    ├── play-sound.sh
    ├── post-edit-lint.sh
    ├── statusbar.sh
    ├── statusline-ccusage.sh
    ├── validate-command.js
    └── *.readme.md
```

## Commandes principales

### Workflows

- `/apex` - Workflow méthodique avec validation utilisateur obligatoire
- `/apex-quick:analyze` - Phase d'analyse uniquement
- `/apex-quick:plan` - Phase de planification uniquement
- `/apex-quick:execute` - Phase d'exécution uniquement
- `/apex-quick:examine` - Phase d'examen uniquement
- `/oneshot` - Exécution autonome sans validation

### Git

- `/git:commit` - Commit rapide avec messages concis
- `/git:push` - Push avec configuration upstream automatique
- `/git:create-pull-request` - Création PR avec titre/description auto-générés
- `/git:review-pr` - Review détaillée d'une PR GitHub
- `/git:watch-ci` - Monitoring CI avec auto-fix des échecs

### Autres

- `/debug` - Débogage de bugs UI/TypeScript/CI
- `/deep-code-analysis` - Analyse approfondie de code
- `/create-skill` - Création interactive d'agents/commandes
- `/cleanup-context` - Optimisation des fichiers memory bank
- `/copywriter` - Coach copywriting avec 5 styles d'écriture

## Agents

- **copywriter** : Coach copywriting avec styles multiples
- **deep-research** : Recherche web approfondie multi-sources
- **explore-codebase** : Exploration rapide de codebase (haiku)
- **security-expert** : Spécialiste cybersécurité et sécurité défensive
- **seo-performance** : Optimisation SEO et performance web
- **snipper** : Modifications de code rapides et optimisées

## Scripts

Les scripts utilitaires sont disponibles dans `scripts/` :

- **validate-command.js** : Validation des commandes Bash (hook PreToolUse)
- **post-edit-lint.sh** : Linting post-édition (hook PostToolUse)
- **statusline-ccusage.sh** : Affichage usage Claude Code dans statusline
- **play-sound.sh** : Sons de notification
- **commit.sh** : Helper pour commits
- **create-worktree.sh / delete-worktree.sh** : Gestion git worktrees

## Installation

1. Copier le dossier `cc-workflow` dans votre répertoire de plugins Claude Code
2. Les agents, commandes et scripts seront automatiquement découverts
3. Redémarrer Claude Code pour activer le plugin

## Utilisation

Les commandes sont invoquées avec `/nom-commande`, par exemple :

```
/apex Ajouter une nouvelle fonctionnalité d'authentification
/oneshot Corriger le bug de validation du formulaire
/git:commit
```

## Auteur

Jordan Bastin

## Version

1.0.0
