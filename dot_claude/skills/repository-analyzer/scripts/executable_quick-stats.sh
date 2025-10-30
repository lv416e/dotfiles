#!/usr/bin/env bash
# Quick repository statistics collector
# Usage: ./quick-stats.sh [path]

set -euo pipefail

REPO_PATH="${1:-.}"

echo "=== Repository Statistics ==="
echo ""

# Basic info
echo "📁 Repository: $(basename "$(cd "$REPO_PATH" && pwd)")"
echo "📍 Location: $(cd "$REPO_PATH" && pwd)"
echo ""

# Git info (if applicable)
if [ -d "$REPO_PATH/.git" ]; then
    echo "=== Git Information ==="
    cd "$REPO_PATH"
    echo "Branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"
    echo "Remote: $(git remote get-url origin 2>/dev/null || echo 'N/A')"
    echo "Last commit: $(git log -1 --format='%h - %s (%ar)' 2>/dev/null || echo 'N/A')"
    echo "Total commits: $(git rev-list --count HEAD 2>/dev/null || echo 'N/A')"
    echo ""
fi

# File statistics
echo "=== File Statistics ==="
echo "Total files: $(find "$REPO_PATH" -type f 2>/dev/null | wc -l | tr -d ' ')"
echo "Total directories: $(find "$REPO_PATH" -type d 2>/dev/null | wc -l | tr -d ' ')"
echo ""

# Language breakdown (by extension)
echo "=== File Types (Top 10) ==="
find "$REPO_PATH" -type f -name "*.*" 2>/dev/null | \
    sed 's/.*\.//' | \
    sort | uniq -c | sort -rn | head -10 | \
    awk '{printf "%-20s %s files\n", $2, $1}'
echo ""

# Size information
echo "=== Size Information ==="
echo "Total size: $(du -sh "$REPO_PATH" 2>/dev/null | cut -f1)"
echo ""

# Configuration files
echo "=== Configuration Files Found ==="
for config in \
    package.json \
    Cargo.toml \
    pyproject.toml \
    requirements.txt \
    go.mod \
    Gemfile \
    composer.json \
    Makefile \
    CMakeLists.txt \
    .chezmoi.toml.tmpl \
    chezmoi.toml \
    Dockerfile \
    docker-compose.yml \
    .github/workflows \
    .gitlab-ci.yml
do
    if [ -e "$REPO_PATH/$config" ]; then
        echo "  ✓ $config"
    fi
done
echo ""

# Documentation files
echo "=== Documentation Files Found ==="
for doc in README.md CONTRIBUTING.md LICENSE CHANGELOG.md CODE_OF_CONDUCT.md; do
    if [ -f "$REPO_PATH/$doc" ]; then
        size=$(wc -l < "$REPO_PATH/$doc" 2>/dev/null | tr -d ' ')
        echo "  ✓ $doc ($size lines)"
    fi
done
echo ""

echo "✓ Statistics collection complete"
