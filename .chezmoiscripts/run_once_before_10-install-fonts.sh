#!/usr/bin/env bash
#
# Install required Nerd Fonts for terminal configuration
# This script runs once before applying dotfiles
#
# Note: Fonts are only installed on macOS (casks not supported on Linux)
# In DevContainers/Codespaces, fonts are rendered by the client machine
#

set -euo pipefail

# Detect OS
OS="$(uname -s)"

case "$OS" in
    Darwin*)
        echo "📦 Installing HackGen Nerd Font (macOS)..."

        # Check if Homebrew is available
        if ! command -v brew &>/dev/null; then
            echo "⚠️  Homebrew not found. Skipping font installation."
            exit 0
        fi

        # Install HackGen Nerd Font if not already installed
        if ! brew list --cask font-hackgen-nerd &>/dev/null 2>&1; then
            echo "   Installing font-hackgen-nerd via Homebrew..."
            if brew install --cask font-hackgen-nerd; then
                echo "✅ HackGen Nerd Font installed successfully"
            else
                echo "⚠️  Font installation failed, but continuing..."
            fi
        else
            echo "✅ HackGen Nerd Font is already installed"
        fi

        # Verify installation (fc-list is available on macOS)
        if command -v fc-list &>/dev/null && fc-list | grep -qi "hackgen"; then
            echo "✅ Font verification passed"
        fi
        ;;

    Linux*)
        echo "ℹ️  Skipping font installation on Linux"
        echo "   Fonts in DevContainers/Codespaces are rendered by your local machine"
        echo "   Please install Nerd Fonts locally: https://www.nerdfonts.com/"
        ;;

    *)
        echo "⚠️  Unknown OS: $OS"
        echo "   Skipping font installation"
        ;;
esac
