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
