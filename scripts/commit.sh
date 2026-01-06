#!/bin/bash

# Smart Commit Script avec bonnes pratiques
# Usage: ./smart-commit.sh [type] [description]

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Smart Commit - Analyse des changements...${NC}"

# Vérifier si on est dans un repo git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Erreur: Vous n'êtes pas dans un repository git${NC}"
    exit 1
fi

# Vérifier s'il y a des changements
if git diff --quiet && git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  Aucun changement détecté${NC}"
    exit 0
fi

echo -e "${BLUE}📊 État du repository:${NC}"
git status --short

# Ajouter automatiquement tous les fichiers modifiés
echo -e "\n${YELLOW}Ajout automatique des fichiers modifiés...${NC}"
git add -A

echo -e "\n${BLUE}📝 Résumé des changements:${NC}"
git --no-pager diff --cached --stat --color=always

# Fonction pour analyser les changements avec Claude Code
analyze_changes_with_claude() {
    local files_changed=$(git diff --cached --name-only)
    local diff_stats=$(git diff --cached --stat)
    local diff_summary=$(git diff --cached --numstat)
    
    # Créer un prompt structuré pour Claude
    local analysis_prompt="Analyze these git changes and generate a Conventional Commits compliant message.

Modified files:
$files_changed

Statistics:
$diff_stats

Numeric summary (additions/deletions/file):
$diff_summary

Follow Conventional Commits specification (https://www.conventionalcommits.org/):

Main types:
- feat: A new feature
- fix: A bug fix
- docs: Documentation only changes
- style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- refactor: A code change that neither fixes a bug nor adds a feature
- perf: A code change that improves performance
- test: Adding missing tests or correcting existing tests
- build: Changes that affect the build system or external dependencies
- ci: Changes to CI configuration files and scripts
- chore: Other changes that don't modify src or test files
- revert: Reverts a previous commit

Additional types (optional but useful):
- improvement: Improves a current implementation without adding a new feature or fixing a bug
- cleanup: Remove deprecated code or unused dependencies
- security: Fix security issues
- deps: Update dependencies
- breaking: Introduce breaking changes (usually with BREAKING CHANGE in footer)
- wip: Work in progress
- config: Configuration changes
- release: Release/Version tags
- merge: Merge branches

You can also add a scope in parentheses after the type when relevant, for example:
- feat(auth): add OAuth2 support
- fix(api): handle null responses
- docs(readme): update installation steps
- style(css): fix indentation
- build(docker): optimize image size
- ci(github): add deployment workflow

Generate the most appropriate type based on the actual changes, not just these examples.
Return ONLY a JSON object with 'type' and 'description' fields.
The description should be in English, concise (max 50 chars), start with lowercase, and not repeat the type.
Include scope if it makes sense based on the files changed.
Example: {\"type\":\"feat(auth)\",\"description\":\"add OAuth2 login support\"}"
    
    # Appeler Claude avec la même approche que create-worktree
    local claude_output=$(claude -p "$analysis_prompt" --output-format json --dangerously-skip-permissions 2>/dev/null)
    
    # Extraire le résultat avec jq
    local result=$(echo "$claude_output" | jq -r '.result' 2>/dev/null)
    
    # Si le résultat contient déjà un JSON valide, l'utiliser, sinon fallback
    if echo "$result" | jq -e . >/dev/null 2>&1; then
        echo "$result"
    else
        echo '{"type":"chore","description":"update project files"}'
    fi
}

# Fonction pour analyser les changements (fallback si Claude n'est pas disponible)
analyze_changes() {
    local files_changed=$(git diff --cached --name-only)
    local diff_output=$(git diff --cached)
    local diff_stats=$(git diff --cached --numstat)
    
    # Analyser les types de fichiers modifiés
    local has_tests=false
    local has_docs=false
    local has_config=false
    local has_src=false
    local has_new_files=false
    local has_deleted_files=false
    
    # Compteurs pour l'analyse
    local total_additions=0
    local total_deletions=0
    local files_count=0
    
    # Calculer les statistiques globales
    while read -r additions deletions file; do
        # Vérifier que les valeurs sont numériques
        if [[ "$additions" =~ ^[0-9]+$ ]] && [[ "$deletions" =~ ^[0-9]+$ ]]; then
            total_additions=$((total_additions + additions))
            total_deletions=$((total_deletions + deletions))
            files_count=$((files_count + 1))
        fi
    done <<< "$diff_stats"
    
    # Vérifier les types de fichiers
    while read -r file; do
        if [[ "$file" =~ \.(test|spec)\. ]] || [[ "$file" =~ ^tests?/ ]] || [[ "$file" =~ /__tests__/ ]]; then
            has_tests=true
        elif [[ "$file" =~ \.(md|txt|rst)$ ]] || [[ "$file" =~ ^docs?/ ]] || [[ "$file" == "README"* ]]; then
            has_docs=true
        elif [[ "$file" =~ \.(json|yaml|yml|toml|ini|conf|config)$ ]] || [[ "$file" =~ ^\..*rc$ ]] || [[ "$file" == "Makefile" ]] || [[ "$file" == "Dockerfile" ]] || [[ "$file" =~ \.(sh|bash)$ ]]; then
            has_config=true
        else
            has_src=true
        fi
    done <<< "$files_changed"
    
    # Vérifier les nouveaux fichiers et suppressions
    local new_files_count=$(git diff --cached --name-status | grep -c "^A" || echo 0)
    local deleted_files_count=$(git diff --cached --name-status | grep -c "^D" || echo 0)
    local modified_files_count=$(git diff --cached --name-status | grep -c "^M" || echo 0)
    
    if [ $new_files_count -gt 0 ]; then
        has_new_files=true
    fi
    if [ $deleted_files_count -gt 0 ]; then
        has_deleted_files=true
    fi
    
    # Analyser le contenu des changements de manière plus précise
    local has_bug_fix=false
    local has_new_feature=false
    local has_refactor=false
    local has_style_only=false
    local has_perf=false
    
    # Analyse plus fine des mots-clés (uniquement dans les lignes ajoutées)
    local added_lines=$(echo "$diff_output" | grep "^+" | grep -v "^+++")
    
    # Détection de fix : chercher des patterns spécifiques
    if echo "$added_lines" | grep -iqE "(fix|fixed|fixes|fixing|resolve|resolved|resolves|resolving|bug|issue|problem|error|correct|corrected|repair)"; then
        # Vérifier que ce n'est pas juste un commentaire ou une documentation
        if $has_src && [ $modified_files_count -gt 0 ]; then
            has_bug_fix=true
        fi
    fi
    
    # Détection de nouvelle fonctionnalité
    if [ $new_files_count -gt 0 ] && $has_src; then
        has_new_feature=true
    elif [ $total_additions -gt $total_deletions ] && [ $((total_additions - total_deletions)) -gt 20 ]; then
        # Si beaucoup plus d'ajouts que de suppressions
        has_new_feature=true
    fi
    
    # Détection de refactoring
    if [ $total_additions -gt 10 ] && [ $total_deletions -gt 10 ] && [ $((total_additions - total_deletions)) -lt 10 ] && [ $((total_deletions - total_additions)) -lt 10 ]; then
        # Si nombre similaire d'ajouts et de suppressions
        has_refactor=true
    fi
    
    # Détection de changements de performance
    if echo "$added_lines" | grep -iqE "(performance|optimize|optimization|speed|faster|cache|caching)"; then
        has_perf=true
    fi
    
    # Vérifier si ce sont seulement des changements de style
    if [ $files_count -eq 1 ] && echo "$diff_output" | grep -qE "^[+-][[:space:]]*$" && [ $total_additions -lt 5 ] && [ $total_deletions -lt 5 ]; then
        has_style_only=true
    fi
    
    # Logique de décision améliorée avec priorités
    if $has_tests && ! $has_src; then
        echo "test"
    elif $has_docs && ! $has_src && ! $has_config; then
        echo "docs"
    elif $has_bug_fix && $has_src; then
        echo "fix"
    elif $has_perf && $has_src; then
        echo "perf"
    elif $has_refactor && $has_src && ! $has_new_feature; then
        echo "refactor"
    elif $has_new_feature || ($has_new_files && $has_src); then
        echo "feat"
    elif $has_style_only; then
        echo "style"
    elif $has_config && ! $has_src; then
        echo "chore"
    elif [ $files_count -eq 1 ] && [ $total_additions -lt 10 ] && [ $total_deletions -lt 10 ]; then
        # Petits changements dans un seul fichier
        echo "fix"
    else
        echo "chore"
    fi
}

# Fonction pour générer une description automatique
generate_description() {
    local files_changed=$(git diff --cached --name-only | wc -l | tr -d ' ')
    local files_list=$(git diff --cached --name-only | head -3 | xargs basename -a 2>/dev/null | tr '\n' ' ')
    local commit_type=$1
    
    # Générer une description basée sur les fichiers modifiés
    case $commit_type in
        "feat")
            if [[ $files_changed -eq 1 ]]; then
                echo "add new functionality in $(echo $files_list | tr -d ' ')"
            else
                echo "add new features across $files_changed files"
            fi
            ;;
        "fix")
            if [[ $files_changed -eq 1 ]]; then
                echo "resolve issue in $(echo $files_list | tr -d ' ')"
            else
                echo "fix bugs in $files_changed files"
            fi
            ;;
        "docs")
            echo "update documentation"
            ;;
        "test")
            echo "add/update tests"
            ;;
        "style")
            echo "improve code formatting"
            ;;
        "refactor")
            if [[ $files_changed -eq 1 ]]; then
                echo "refactor $(echo $files_list | tr -d ' ')"
            else
                echo "refactor code structure"
            fi
            ;;
        "chore")
            if echo "$files_list" | grep -q "package.json\|yarn.lock\|pnpm-lock\|requirements"; then
                echo "update dependencies"
            else
                echo "maintenance and configuration updates"
            fi
            ;;
        *)
            echo "update project files"
            ;;
    esac
}

# Analyse automatique des changements
echo -e "\n${BLUE}🤖 Analyse automatique des changements...${NC}"

# Essayer d'abord avec Claude Code
if command -v claude &> /dev/null && command -v jq &> /dev/null; then
    echo -e "${YELLOW}🤖 Utilisation de Claude Code pour l'analyse...${NC}"
    CLAUDE_RESPONSE=$(analyze_changes_with_claude)
    
    # Extraire le type et la description avec jq
    COMMIT_TYPE=$(echo "$CLAUDE_RESPONSE" | jq -r '.type' 2>/dev/null)
    COMMIT_DESCRIPTION=$(echo "$CLAUDE_RESPONSE" | jq -r '.description' 2>/dev/null)
    
    # Vérifier que les valeurs sont valides
    if [ -n "$COMMIT_TYPE" ] && [ "$COMMIT_TYPE" != "null" ] && [ -n "$COMMIT_DESCRIPTION" ] && [ "$COMMIT_DESCRIPTION" != "null" ]; then
        echo -e "${GREEN}✅ Analyse Claude Code réussie${NC}"
    else
        # Fallback si le parsing échoue
        echo -e "${YELLOW}⚠️  Parsing Claude échoué, utilisation du fallback...${NC}"
        COMMIT_TYPE=$(analyze_changes)
        COMMIT_DESCRIPTION=$(generate_description $COMMIT_TYPE)
    fi
else
    # Utiliser la méthode classique si Claude ou jq n'est pas disponible
    if ! command -v claude &> /dev/null; then
        echo -e "${YELLOW}Claude Code non disponible, analyse locale...${NC}"
    else
        echo -e "${YELLOW}jq non disponible, analyse locale...${NC}"
    fi
    COMMIT_TYPE=$(analyze_changes)
    COMMIT_DESCRIPTION=$(generate_description $COMMIT_TYPE)
fi

COMMIT_BODY=""

echo -e "${GREEN}Type détecté: ${COMMIT_TYPE}${NC}"
echo -e "${GREEN}Description générée: ${COMMIT_DESCRIPTION}${NC}"

# Validation de la description
if [ ${#COMMIT_DESCRIPTION} -gt 50 ]; then
    echo -e "${YELLOW}⚠️  Attention: La description dépasse 50 caractères (${#COMMIT_DESCRIPTION})${NC}"
fi

# Construire le message de commit
COMMIT_MESSAGE="${COMMIT_TYPE}: ${COMMIT_DESCRIPTION}"
if [ -n "$COMMIT_BODY" ]; then
    COMMIT_MESSAGE="${COMMIT_MESSAGE}

${COMMIT_BODY}"
fi

echo -e "\n${BLUE}📋 Message de commit généré:${NC}"
echo -e "${GREEN}${COMMIT_MESSAGE}${NC}"

# Commit automatique
git commit -m "$COMMIT_MESSAGE"
echo -e "\n${GREEN}✅ Commit créé avec succès!${NC}"

# Afficher la branche courante pour information
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Branche actuelle: ${CURRENT_BRANCH}${NC}"
echo -e "${YELLOW}💡 Pour pusher : git push origin ${CURRENT_BRANCH}${NC}"
