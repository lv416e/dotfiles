#!/usr/bin/env bash
#
# Install required Nerd Fonts for terminal configuration
# This script runs once before applying dotfiles
#

set -euo pipefail

echo "📦 Installing HackGen Nerd Font..."

# Check if Homebrew is available
if ! command -v brew &>/dev/null; then
    echo "⚠️  Homebrew not found. Skipping font installation."
    echo "   Please install Homebrew first: https://brew.sh"
    exit 0
fi

# Install HackGen Nerd Font if not already installed
if ! brew list --cask font-hackgen-nerd &>/dev/null; then
    echo "   Installing font-hackgen-nerd via Homebrew..."
    brew install --cask font-hackgen-nerd
    echo "✅ HackGen Nerd Font installed successfully"
else
    echo "✅ HackGen Nerd Font is already installed"
fi

# Verify installation
if fc-list | grep -qi "hackgen"; then
    echo "✅ Font verification passed"
else
    echo "⚠️  Font installation may have failed. Please check manually."
fi
