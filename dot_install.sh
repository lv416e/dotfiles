#!/bin/bash
# =============================================================================
# Chezmoi Non-Interactive Installer for DevContainers/Codespaces
# =============================================================================
# This script is automatically invoked by VS Code DevContainers and GitHub
# Codespaces to apply dotfiles. It must be non-interactive.
#
# Environment Detection:
#   - CODESPACES=true        → GitHub Codespaces
#   - REMOTE_CONTAINERS=true → VS Code DevContainer
#
# Usage:
#   ./install.sh             → Run manually (non-interactive)
#   Automatic in containers  → Triggered by VS Code/Codespaces
#
# References:
#   - https://www.chezmoi.io/user-guide/machines/containers-and-vms/
#   - https://code.visualstudio.com/docs/devcontainers/containers
# =============================================================================

set -euo pipefail

# Colors for output (if terminal supports it)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m' # No Color
else
  RED=''
  GREEN=''
  YELLOW=''
  NC=''
fi

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# Environment Detection
# =============================================================================

if [ "${CODESPACES:-false}" = "true" ]; then
  CONTAINER_TYPE="codespaces"
  log_info "Running in GitHub Codespaces"
elif [ "${REMOTE_CONTAINERS:-false}" = "true" ]; then
  CONTAINER_TYPE="devcontainer"
  log_info "Running in VS Code DevContainer"
else
  CONTAINER_TYPE="local"
  log_info "Running on local machine"
fi

# =============================================================================
# Install Chezmoi (if not present)
# =============================================================================

if ! command -v chezmoi &> /dev/null; then
  log_info "Installing chezmoi..."

  # Use official install script (non-interactive)
  if command -v curl &> /dev/null; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
  elif command -v wget &> /dev/null; then
    sh -c "$(wget -qO- get.chezmoi.io)" -- -b "${HOME}/.local/bin"
  else
    log_error "Neither curl nor wget found. Cannot install chezmoi."
    exit 1
  fi

  # Add to PATH for this session
  export PATH="${HOME}/.local/bin:${PATH}"

  log_info "Chezmoi installed to ~/.local/bin/chezmoi"
else
  log_info "Chezmoi already installed: $(command -v chezmoi)"
fi

# =============================================================================
# Apply Dotfiles
# =============================================================================

# Container environments clone dotfiles to ~/dotfiles automatically
if [ "$CONTAINER_TYPE" != "local" ] && [ -d "${HOME}/dotfiles" ]; then
  log_info "Applying dotfiles from ~/dotfiles (container environment)..."
  chezmoi init --apply --source="${HOME}/dotfiles"
else
  log_info "Applying dotfiles from chezmoi source..."
  chezmoi apply
fi

# =============================================================================
# Install Development Tools (mise)
# =============================================================================

if command -v mise &> /dev/null; then
  log_info "Installing mise-managed development tools..."

  # Container-specific optimizations
  if [ "$CONTAINER_TYPE" != "local" ]; then
    # Disable auto-update in containers for faster startup
    export HOMEBREW_NO_AUTO_UPDATE=1
    export MISE_EXPERIMENTAL=1
  fi

  # Install all tools from config (non-interactive)
  mise install --yes

  log_info "Mise tools installed successfully"
else
  log_warn "Mise not found. Skipping tool installation."
  log_warn "Mise should be installed via Homebrew or added to your dotfiles."
fi

# =============================================================================
# Container-Specific Setup
# =============================================================================

if [ "$CONTAINER_TYPE" != "local" ]; then
  log_info "Applying container-specific optimizations..."

  # Disable analytics/telemetry in containers
  export HOMEBREW_NO_ANALYTICS=1

  # Create marker file to detect container environment in shell configs
  mkdir -p "${HOME}/.config"
  echo "$CONTAINER_TYPE" > "${HOME}/.config/container-type"

  log_info "Container type marker: ~/.config/container-type"
fi

# =============================================================================
# Completion
# =============================================================================

log_info "✅ Dotfiles installation complete!"

if [ "$CONTAINER_TYPE" != "local" ]; then
  log_info "Container environment ready. Reload shell or restart terminal."
else
  log_info "Run 'exec zsh' or restart your terminal to apply changes."
fi
