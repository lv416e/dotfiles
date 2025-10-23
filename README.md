# dotfiles

![CI](https://github.com/lv416e/dotfiles/workflows/Dotfiles%20CI/badge.svg)
![License](https://img.shields.io/github/license/lv416e/dotfiles)

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## Installation

```sh
# 1. Install prerequisites
brew install chezmoi age 1password-cli

# 2. Configure git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 3. Initialize dotfiles (DO NOT use --apply yet)
chezmoi init lv416e/dotfiles

# 4. Set up secrets
eval $(op signin)  # Sign in to 1Password
mkdir -p ~/.config/chezmoi
op item get "Chezmoi Age Key" --fields notesPlain --vault Personal > ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt

# 5. Apply dotfiles
chezmoi apply

# 6. Install packages
chezmoi cd
brew bundle install
mise install
```

See [New Machine Setup](docs/NEW_MACHINE_SETUP.md) for detailed instructions and troubleshooting.

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
