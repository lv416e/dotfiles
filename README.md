# dotfiles

![CI](https://github.com/lv416e/dotfiles/workflows/Dotfiles%20CI/badge.svg)
![License](https://img.shields.io/github/license/lv416e/dotfiles)
[![chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-blue)](https://www.chezmoi.io/)

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

> [!WARNING]
> Fork this repository and review the code before use. Don't blindly use my settings unless you know what they do. Use at your own risk!

## For New Users

To use this repository as a template:

1. Fork this repository to your GitHub account
2. Update step 3 below: Replace `lv416e/dotfiles` with `YOUR_USERNAME/dotfiles`
3. Follow the installation steps below - you'll be prompted for your configuration
4. See [Fork Guide](FORK.md) for detailed instructions

## Installation

### 1. Install prerequisites

First, install Homebrew if not already installed:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install required tools:

```sh
brew install chezmoi age 1password-cli
```

### 2. Configure git

```sh
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. Initialize dotfiles

You'll be prompted for configuration (email, vault name, encryption options, etc.):

```sh
chezmoi init lv416e/dotfiles
```

### 4. Set up secrets (optional)

If you enabled 1Password integration during initialization:

```sh
op signin
```

If you enabled age encryption, generate your key:

```sh
chezmoi age-keygen --output ~/.config/chezmoi/key.txt
```

> [!NOTE]
> These steps are optional. The repository works without 1Password or age encryption.

### 5. Apply dotfiles

```sh
chezmoi apply -v
```

### 6. Install packages

```sh
cd ~/.local/share/chezmoi
brew bundle install
mise install
mise trust
```

See [New Machine Setup Guide](docs/getting-started/new-machine-setup.md) for detailed instructions and troubleshooting.

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

## Features

- **Multiplexer Abstraction**: Seamless tmux/zellij switching with `switch-multiplexer`
- **Configuration Switching**: Switch between modular/monolithic zsh configs with `switch-zsh-config`
- **Secrets Management**: Integrated 1Password CLI and age encryption
- **Pre-Commit Hooks**: Automatic secret detection with lefthook and gitleaks
- **Modern Tools**: jj, WezTerm, Zellij, and 90+ packages
- **Automated Tasks**: 24 mise tasks for common workflows (`mise tasks`)
- **CI/CD**: GitHub Actions validates configurations

## Documentation

- [New Machine Setup Guide](docs/getting-started/new-machine-setup.md) - Complete setup guide
- [Fork Guide](FORK.md) - Fork and customize instructions
- [Secrets Management](docs/guides/secrets-management.md) - 1Password and age encryption
- [Pre-Commit Hooks](docs/explanation/pre-commit-hooks.md) - Git hooks with lefthook and gitleaks
- [Zsh Config Switching](docs/guides/zsh-config-switching.md) - Modular vs monolithic
- [Multiplexer Abstraction](docs/explanation/multiplexer-abstraction.md) - Unified tmux/zellij interface
- [Keybindings Reference](docs/reference/keybindings.md) - Quick reference for tmux/zellij
- [Modern Tools](docs/guides/modern-tools.md) - jj, WezTerm, Zellij guides
- [Mise Tasks](docs/reference/mise-tasks.md) - Task runner documentation
