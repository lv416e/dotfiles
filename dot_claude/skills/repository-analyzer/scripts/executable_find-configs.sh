#!/usr/bin/env bash
# Find and categorize configuration files
# Usage: ./find-configs.sh [path]

set -euo pipefail

REPO_PATH="${1:-.}"

echo "=== Configuration File Discovery ==="
echo ""

# Package managers
echo "📦 Package Managers:"
find "$REPO_PATH" -maxdepth 3 \( \
    -name "package.json" -o \
    -name "package-lock.json" -o \
    -name "yarn.lock" -o \
    -name "pnpm-lock.yaml" -o \
    -name "Cargo.toml" -o \
    -name "Cargo.lock" -o \
    -name "pyproject.toml" -o \
    -name "requirements.txt" -o \
    -name "Pipfile" -o \
    -name "poetry.lock" -o \
    -name "go.mod" -o \
    -name "go.sum" -o \
    -name "Gemfile" -o \
    -name "Gemfile.lock" -o \
    -name "composer.json" -o \
    -name "composer.lock" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# Build tools
echo "🔨 Build Tools:"
find "$REPO_PATH" -maxdepth 3 \( \
    -name "Makefile" -o \
    -name "CMakeLists.txt" -o \
    -name "build.gradle" -o \
    -name "pom.xml" -o \
    -name "webpack.config.js" -o \
    -name "vite.config.js" -o \
    -name "rollup.config.js" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# Version managers
echo "🔢 Version Managers:"
find "$REPO_PATH" -maxdepth 3 \( \
    -name ".nvmrc" -o \
    -name ".ruby-version" -o \
    -name ".python-version" -o \
    -name ".tool-versions" -o \
    -name ".node-version" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# Linters & Formatters
echo "✨ Linters & Formatters:"
find "$REPO_PATH" -maxdepth 3 \( \
    -name ".eslintrc*" -o \
    -name ".prettierrc*" -o \
    -name ".stylelintrc*" -o \
    -name ".rubocop.yml" -o \
    -name "pylint.rc" -o \
    -name ".flake8" -o \
    -name "rustfmt.toml" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# TypeScript
echo "📘 TypeScript:"
find "$REPO_PATH" -maxdepth 3 \( \
    -name "tsconfig.json" -o \
    -name "tsconfig.*.json" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# Docker
echo "🐳 Docker:"
find "$REPO_PATH" -maxdepth 3 \( \
    -name "Dockerfile" -o \
    -name "docker-compose.yml" -o \
    -name "docker-compose.*.yml" -o \
    -name ".dockerignore" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# CI/CD
echo "🚀 CI/CD:"
find "$REPO_PATH" \( \
    -path "*/.github/workflows/*.yml" -o \
    -path "*/.github/workflows/*.yaml" -o \
    -name ".gitlab-ci.yml" -o \
    -name ".circleci/config.yml" -o \
    -name "azure-pipelines.yml" -o \
    -name "Jenkinsfile" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# Git
echo "🌿 Git:"
find "$REPO_PATH" -maxdepth 2 \( \
    -name ".gitignore" -o \
    -name ".gitattributes" -o \
    -name ".gitmodules" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# Editor configs
echo "⚙️  Editor Configs:"
find "$REPO_PATH" -maxdepth 3 \( \
    -name ".editorconfig" -o \
    -name ".vscode" -o \
    -name ".idea" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# Environment
echo "🔐 Environment:"
find "$REPO_PATH" -maxdepth 3 \( \
    -name ".env.example" -o \
    -name ".env.template" -o \
    -name ".envrc" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

# chezmoi specific
echo "🏠 Chezmoi:"
find "$REPO_PATH" -maxdepth 3 \( \
    -name ".chezmoi.toml.tmpl" -o \
    -name "chezmoi.toml" -o \
    -name ".chezmoiignore" -o \
    -name ".chezmoiroot" -o \
    -name ".chezmoitemplates" \
\) 2>/dev/null | sed "s|$REPO_PATH/||" | sort
echo ""

echo "✓ Configuration discovery complete"
