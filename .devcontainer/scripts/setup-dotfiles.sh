#!/bin/bash
# =============================================================================
# DevContainer Dotfiles Setup Script
# =============================================================================
# Installs and applies chezmoi-managed dotfiles in a devcontainer environment.
#
# Usage:
#   bash setup-dotfiles.sh [DOTFILES_REPO_URL]
#
# Environment Variables:
#   DOTFILES_REPO - Override default dotfiles repository
#                   Default: https://github.com/lv416e/dotfiles.git
# =============================================================================

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# =============================================================================
# Configuration
# =============================================================================

# Dotfiles repository (can be overridden by env var or argument)
DOTFILES_REPO="${DOTFILES_REPO:-${1:-https://github.com/lv416e/dotfiles.git}}"

log_info "==================================================================="
log_info "DevContainer Dotfiles Setup"
log_info "==================================================================="
log_info "Repository: $DOTFILES_REPO"
log_info ""

# =============================================================================
# Install chezmoi
# =============================================================================

if command -v chezmoi >/dev/null 2>&1; then
    log_info "chezmoi already installed: $(chezmoi --version)"
else
    log_info "Installing chezmoi..."

    # Install to user's local bin (doesn't require sudo)
    if sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"; then
        log_info "✅ chezmoi installed to $HOME/.local/bin"
    else
        log_error "Failed to install chezmoi"
        exit 1
    fi
fi

# Ensure chezmoi is in PATH
export PATH="$HOME/.local/bin:$PATH"

# =============================================================================
# Install Homebrew
# =============================================================================

if command -v brew >/dev/null 2>&1; then
    log_info "Homebrew already installed: $(brew --version | head -n1)"
else
    log_info "Installing Homebrew..."

    # Non-interactive installation for Linux environments
    if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_info "✅ Homebrew installed successfully"

        # Configure PATH for current session
        if [ -d "/home/linuxbrew/.linuxbrew" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            log_info "Homebrew configured at /home/linuxbrew/.linuxbrew"
        fi
    else
        log_warn "⚠️  Homebrew installation failed, continuing without it"
    fi
fi

# =============================================================================
# Initialize and apply dotfiles
# =============================================================================

CHEZMOI_DIR="$HOME/.local/share/chezmoi"

if [ -d "$CHEZMOI_DIR" ]; then
    log_info "Dotfiles already initialized, updating..."
    if chezmoi update --apply --verbose; then
        log_info "✅ Dotfiles updated successfully"
    else
        log_warn "⚠️  Dotfiles update encountered errors (this may be expected)"
    fi
else
    log_info "Initializing dotfiles from $DOTFILES_REPO..."
    if chezmoi init --apply --verbose "$DOTFILES_REPO"; then
        log_info "✅ Dotfiles initialized and applied successfully"
    else
        log_error "Failed to initialize dotfiles"
        exit 1
    fi
fi

# =============================================================================
# Verify setup
# =============================================================================

log_info ""
log_info "==================================================================="
log_info "Verification"
log_info "==================================================================="

# Check managed files
MANAGED_COUNT=$(chezmoi managed | wc -l)
log_info "Managed files: $MANAGED_COUNT"

# Check shell
log_info "Current SHELL: ${SHELL}"
log_info "Default shell: $(getent passwd "$USER" | cut -d: -f7)"

# Check zsh availability
if command -v zsh >/dev/null 2>&1; then
    log_info "zsh: $(zsh --version)"
else
    log_warn "zsh not found"
fi

log_info ""
log_info "==================================================================="
log_info "✅ Setup Complete!"
log_info "==================================================================="
log_info ""
log_info "Next steps:"
log_info "  1. Open a new terminal (should default to zsh)"
log_info "  2. Verify with: echo \$SHELL"
log_info "  3. Check dotfiles with: chezmoi managed"
log_info ""
