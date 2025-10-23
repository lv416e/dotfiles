# dotfiles

![CI](https://github.com/lv416e/dotfiles/workflows/Dotfiles%20CI/badge.svg)
![License](https://img.shields.io/github/license/lv416e/dotfiles)

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## ✨ Features

- 🔧 **Configuration Switching**: Seamlessly switch between modular and monolithic zsh configs
- 🔐 **Secrets Management**: Integrated 1Password CLI and age encryption
- 🚀 **Performance Optimized**: 48.7ms zsh startup time with deferred loading
- 📦 **Modern Tools**: Includes jj (Jujutsu), WezTerm, Zellij, and 90+ packages
- 🔄 **Automated CI/CD**: GitHub Actions workflow validates configurations
- 📝 **Comprehensive Documentation**: Detailed guides for all features

## Installation

### Prerequisites

#### 1. Install Homebrew (if not already installed)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. Install chezmoi

```sh
brew install chezmoi
```

#### 3. Configure git

Before installing, make sure your git config is set up:

```sh
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

> [!NOTE]
> This setup reads your name and email directly from git config, so no personal information is hardcoded in the repository.

### Install on a new machine

```sh
chezmoi init --apply lv416e/dotfiles
```

## Daily Usage

### Editing files

```sh
chezmoi edit ~/.zshrc
```

### Applying changes

```sh
chezmoi apply
```

### Committing changes

```sh
chezmoi git add -A
chezmoi git -- commit -m "Update configuration"
chezmoi git push
```

Or use a single shell session:

```sh
chezmoi cd
git add -A && git commit -m "Update configuration" && git push
```

## Neovim Configuration

This dotfiles setup includes both **LazyVim** and **AstroNvim** configurations, allowing you to easily switch between them.

### Default Configuration

By default, **LazyVim** is used. The setup is automatically configured when you run `chezmoi apply`.

### Switching Between Configurations

Use the `nvim-switch` command to switch between configurations:

```sh
# Switch to LazyVim
nvim-switch lazyvim

# Switch to AstroNvim
nvim-switch astronvim

# Check current configuration
nvim-switch status
```

### Manual Configuration (Advanced)

To set a specific configuration as default, set the `NVIM_CONFIG` environment variable before running `chezmoi apply`:

```sh
# Use AstroNvim by default
export NVIM_CONFIG=astronvim
chezmoi apply

# Use LazyVim by default
export NVIM_CONFIG=lazyvim
chezmoi apply
```

### Configuration Locations

- **LazyVim**: `~/.config/nvim-lazyvim/`
- **AstroNvim**: `~/.config/nvim-astronvim/`
- **Active Config** (symlink): `~/.config/nvim/`

## Zsh Configuration

This dotfiles setup supports **two zsh configuration styles**:

### Modular Configuration (Default)

Optimized 7-module structure with deferred loading:
- 📁 `~/.config/zsh/conf.d/01-init.zsh` - Core initialization
- 📁 `~/.config/zsh/conf.d/02-plugins.zsh` - Plugin loading
- 📁 `~/.config/zsh/conf.d/03-tools.zsh` - Tool configuration
- 📁 `~/.config/zsh/conf.d/04-env.zsh` - Environment variables
- 📁 `~/.config/zsh/conf.d/05-aliases.zsh` - Aliases (deferred)
- 📁 `~/.config/zsh/conf.d/06-functions.zsh` - Functions (deferred)
- 📁 `~/.config/zsh/conf.d/07-repo.zsh` - Repository management (deferred)

**Performance**: 48.7ms minimum startup time (15% faster than monolithic)

### Monolithic Configuration

Traditional single-file configuration:
- 📄 `~/.zshrc` - All-in-one configuration

### Switching Between Configurations

```sh
# Switch to modular (default)
switch-zsh-config modular

# Switch to monolithic
switch-zsh-config monolithic

# Check current configuration
switch-zsh-config
```

See [docs/ZSH_CONFIG_SWITCHING.md](docs/ZSH_CONFIG_SWITCHING.md) for details.

## Terminal Multiplexers

Choose between **tmux** (traditional) and **Zellij** (modern):

```sh
# Switch to tmux (default)
switch-multiplexer tmux

# Switch to zellij
switch-multiplexer zellij

# Check current multiplexer
switch-multiplexer
```

See [docs/TERMINAL_MULTIPLEXERS.md](docs/TERMINAL_MULTIPLEXERS.md) for details.

## Secrets Management

This setup supports **two complementary approaches**:

### 1Password CLI (Recommended for API tokens)
```sh
# In templates (e.g., ~/.zshenv.tmpl)
export OPENAI_API_KEY="{{ onepasswordRead "op://Personal/OpenAI/api_key" }}"
```

### age Encryption (Recommended for large files)
```sh
# Generate key
chezmoi age-keygen --output=$HOME/.config/chezmoi/key.txt

# Add encrypted files
chezmoi add --encrypt ~/.aws/credentials
```

See [docs/SECRETS_MANAGEMENT.md](docs/SECRETS_MANAGEMENT.md) for setup guide.

## New Modern Tools

### Jujutsu (jj) - Git Alternative
```sh
# Use with existing Git repos
jj git init --colocate

# Universal undo
jj undo

# Branchless workflow
jj new
jj desc -m "Add feature"
```

### WezTerm - Lua-Configurable Terminal
```sh
# Launch WezTerm
wezterm

# Configure in ~/.config/wezterm/wezterm.lua
```

### Zellij - Modern Multiplexer
```sh
# Launch Zellij
zellij

# Built-in UI shows keybindings
```

See [docs/NEW_TOOLS.md](docs/NEW_TOOLS.md) for detailed guides.

## Mise Task Runner

This repository includes **23 automated tasks** for common workflows:

### Quick Start
```sh
# List all tasks
mise tasks

# Common operations
mise up          # Update all tools
mise a           # Apply dotfiles
mise ops         # Sign in to 1Password
mise sv          # Verify secrets setup
```

### Task Categories

**System Maintenance** (`sys-*`):
- `sys-update` (alias: `up`) - Update and prune tools
- `sys-clean` (alias: `c`) - Clean caches
- `sys-health` (alias: `h`) - Health checks
- `sys-bench` (alias: `b`) - Benchmark zsh startup

**Dotfiles** (`dot-*`):
- `dot-apply` (alias: `a`) - Apply dotfiles
- `dot-backup` (alias: `bak`) - Push to remote
- `dot-diff` (alias: `d`) - Show differences

**1Password** (`op-*`):
- `op-signin` (alias: `ops`) - Authenticate
- `op-vaults` (alias: `opv`) - List vaults
- `op-items` (alias: `opi`) - List items

**Secrets** (`secrets-*`):
- `secrets-verify` (alias: `sv`) - Verify setup
- `secrets-add` (alias: `sa`) - Add encrypted file
- `secrets-list` (alias: `sl`) - List encrypted files

**Workflows**:
- `sync` (alias: `sy`) - Full sync
- `fresh` (alias: `f`) - Fresh start

See [docs/MISE_TASKS.md](docs/MISE_TASKS.md) for complete guide.
