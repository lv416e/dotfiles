# dotfiles

![CI](https://github.com/lv416e/dotfiles/workflows/Dotfiles%20CI/badge.svg)
![License](https://img.shields.io/github/license/lv416e/dotfiles)

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## Installation

```sh
# Install chezmoi
brew install chezmoi

# Configure git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Install dotfiles
chezmoi init --apply lv416e/dotfiles
```

See [docs/NEW_MACHINE_SETUP.md](docs/NEW_MACHINE_SETUP.md) for complete setup instructions.

## Daily Usage

```sh
# Edit files
chezmoi edit ~/.zshrc

# Apply changes
chezmoi apply

# Commit and push
chezmoi cd
git add -A && git commit -m "Update configuration" && git push
```

## Features

- **Configuration Switching**: Switch between modular/monolithic zsh configs with `switch-zsh-config`
- **Secrets Management**: Integrated 1Password CLI and age encryption
- **Modern Tools**: jj, WezTerm, Zellij, and 90+ packages
- **Automated Tasks**: 24 mise tasks for common workflows (`mise tasks`)
- **CI/CD**: GitHub Actions validates configurations

## Documentation

- [New Machine Setup](docs/NEW_MACHINE_SETUP.md) - Complete setup guide
- [Secrets Management](docs/SECRETS_MANAGEMENT.md) - 1Password and age encryption
- [Zsh Config Switching](docs/ZSH_CONFIG_SWITCHING.md) - Modular vs monolithic
- [Terminal Multiplexers](docs/TERMINAL_MULTIPLEXERS.md) - tmux vs Zellij
- [Modern Tools](docs/NEW_TOOLS.md) - jj, WezTerm, Zellij guides
- [Mise Tasks](docs/MISE_TASKS.md) - Task runner documentation
