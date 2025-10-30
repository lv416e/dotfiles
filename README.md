# dotfiles

![CI](https://github.com/lv416e/dotfiles/workflows/Dotfiles%20CI/badge.svg)
[![chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-blue)](https://www.chezmoi.io/)

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

> [!WARNING]
> Fork this repository and review the code before use. Don't blindly use my settings unless you know what they do. Use at your own risk!

## Installation

### Quick Start (Interactive Setup)

```bash
# Install prerequisites
brew install chezmoi age 1password-cli

# Configure git (if not already done)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Initialize dotfiles (you'll be prompted for configuration)
chezmoi init YOUR_USERNAME/dotfiles

# Apply dotfiles
chezmoi apply -v

# Install packages
cd ~/.local/share/chezmoi
brew bundle install
mise install
mise trust
```

### Interactive Prompts

When you run `chezmoi init`, you'll be asked:

- **Email address** - Your email (default: from git config)
- **GitHub username** - For repository references
- **1Password vault name** - Vault for secrets (default: "Personal")
- **Use GitHub token from 1Password?** - Optional (default: No)
- **Enable age encryption?** - For encrypted files (default: No)
- **Zsh config style** - Monolithic or modular (default: monolithic)
- **Terminal multiplexer** - tmux or zellij (default: tmux)

> [!NOTE]
> No manual file editing required - all configuration is handled via prompts.

### Detailed Setup

For step-by-step instructions, troubleshooting, and secrets management, see the [New Machine Setup Guide](docs/getting-started/new-machine-setup.md).

## Features

### Fork-Friendly Design

- Interactive setup - zero hardcoded values
- All config via prompts on first run
- Edit `~/.config/chezmoi/chezmoi.toml` to change later

### Dual Secrets Management

- **age**: File-level encryption for static secrets
- **1Password CLI**: Dynamic credentials with fallbacks

### 24 Mise Tasks - Workflow Automation

```bash
mise secrets-verify    # Verify secrets setup
mise sync              # Full sync: apply → update → clean
mise dot-apply         # Apply dotfiles (alias: mise a)
mise op-signin         # 1Password signin (alias: mise ops)
mise sys-health        # System health check
```

### Modern Tool Stack

- **Shell**: zsh with Powerlevel10k
- **Multiplexers**: tmux / Zellij (switchable)
- **Editor**: Neovim with extensive config
- **VCS**: jj (Jujutsu) + git
- **Tools**: 90+ packages via Homebrew + mise

### Security

- Pre-commit hooks (lefthook + gitleaks)
- Automatic secret detection
- Encrypted file support
- CI/CD validation

## Usage

### Daily Operations

```bash
# Quick apply
mise a

# Edit and apply
chezmoi edit ~/.zshrc
chezmoi apply

# Commit and push
chezmoi cd
git add -A && git commit -m "Update config" && git push

# Full system sync
mise sync
```

### Secrets Management

```bash
# Verify setup
mise secrets-verify

# Sign in to 1Password
mise ops

# Add encrypted file (if age enabled)
chezmoi add --encrypt ~/.ssh/id_rsa
```

## Documentation

### Getting Started

- [New Machine Setup](docs/getting-started/new-machine-setup.md) - Complete guide
- [Fork Guide](FORK.md) - Fork and customize instructions

### Configuration

- [Secrets Management](docs/guides/secrets-management.md) - 1Password & age
- [Zsh Config](docs/guides/zsh-config-switching.md) - Modular vs monolithic
- [Multiplexer](docs/guides/multiplexer-abstraction.md) - tmux/zellij switching

### Reference

- [Mise Tasks](docs/reference/mise-tasks.md) - All available tasks
- [Keybindings](docs/reference/keybindings-reference.md) - tmux/zellij keys
- [Pre-Commit Hooks](docs/reference/pre-commit-hooks.md) - Git hooks

### Tools

- [Modern Tools Guide](docs/guides/modern-tools.md) - jj, WezTerm, Zellij

## What's Included

<details>
<summary><strong>Shell & Terminal</strong></summary>

- **zsh** - Fast shell with Powerlevel10k prompt
- **tmux** / **Zellij** - Terminal multiplexers (switchable)
- **WezTerm** - GPU-accelerated terminal emulator
- **starship** - Cross-shell prompt (alternative)

</details>

<details>
<summary><strong>Development Tools</strong></summary>

- **mise** - Universal version manager + task runner
- **jj** (Jujutsu) - Modern VCS (co-exists with git)
- **neovim** - Extensively configured editor
- **gh** - GitHub CLI
- **docker** - Containerization

</details>

<details>
<summary><strong>Productivity</strong></summary>

- **fzf** - Fuzzy finder
- **ripgrep** - Fast search
- **fd** - Fast find
- **bat** - Better cat
- **eza** - Better ls
- **zoxide** - Smart cd

</details>

<details>
<summary><strong>Security & Secrets</strong></summary>

- **age** - Modern encryption tool
- **1password-cli** - Secret management
- **gitleaks** - Secret scanning
- **lefthook** - Fast git hooks

</details>

## Maintenance

```bash
# Update mise tools
mise sys-update

# Update Homebrew packages
brew update && brew upgrade

# Clean caches
mise sys-clean

# Health check
mise sys-health
```
