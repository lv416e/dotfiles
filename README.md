# dotfiles

![CI](https://github.com/lv416e/dotfiles/workflows/Dotfiles%20CI/badge.svg)
![License](https://img.shields.io/github/license/lv416e/dotfiles)

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## For New Users

To use this repository as a template:

1. Fork this repository to your GitHub account
2. Update step 3 below: Replace `lv416e/dotfiles` with `YOUR_USERNAME/dotfiles`
3. Generate your own age encryption key (step 4) and update `.chezmoi.toml.tmpl`
4. Follow the installation steps below

## Installation

### 1. Install prerequisites

```sh
brew install chezmoi age 1password-cli
```
`age` for encrypted files, `1password-cli` for secrets management.

Optional: Install 1Password app for biometric authentication

```sh
brew install --cask 1password
```

### 2. Configure git

```sh
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. Initialize dotfiles

**Important**: Do NOT use `--apply` yet (secrets must be set up first)

```sh
chezmoi init lv416e/dotfiles
```

### 4. Set up secrets

Sign in to 1Password and restore age key:

```sh
eval $(op signin)
```

```sh
mkdir -p ~/.config/chezmoi
op item get "chezmoi-age-key" --fields notesPlain --vault Personal > ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
```

### 5. Apply dotfiles

```sh
chezmoi apply
```

### 6. Install packages

```sh
chezmoi cd
brew bundle install
mise install
```

See [New Machine Setup](docs/NEW_MACHINE_SETUP.md) for detailed instructions and troubleshooting.

## Usage

### Edit files

```sh
chezmoi edit ~/.zshrc
```

### Apply changes

```sh
chezmoi apply
```

### Commit and push

```sh
chezmoi cd
git add -A && git commit -m "Update configuration" && git push
```

## Features

- **Configuration Switching**: Switch between modular/monolithic zsh configs with `switch-zsh-config`
- **Secrets Management**: Integrated 1Password CLI and age encryption
- **Pre-Commit Hooks**: Automatic secret detection with lefthook and gitleaks
- **Modern Tools**: jj, WezTerm, Zellij, and 90+ packages
- **Automated Tasks**: 24 mise tasks for common workflows (`mise tasks`)
- **CI/CD**: GitHub Actions validates configurations

## Documentation

- [New Machine Setup](docs/NEW_MACHINE_SETUP.md) - Complete setup guide
- [Secrets Management](docs/SECRETS_MANAGEMENT.md) - 1Password and age encryption
- [Pre-Commit Hooks](docs/PRE_COMMIT_HOOKS.md) - Git hooks with lefthook and gitleaks
- [Zsh Config Switching](docs/ZSH_CONFIG_SWITCHING.md) - Modular vs monolithic
- [Terminal Multiplexers](docs/TERMINAL_MULTIPLEXERS.md) - tmux vs Zellij
- [Modern Tools](docs/NEW_TOOLS.md) - jj, WezTerm, Zellij guides
- [Mise Tasks](docs/MISE_TASKS.md) - Task runner documentation
