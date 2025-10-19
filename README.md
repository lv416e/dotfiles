# dotfiles

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

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
