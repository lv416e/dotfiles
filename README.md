# dotfiles

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## Installation

### Prerequisites

Before installing, make sure your git config is set up:

```sh
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

> **Note:** This setup reads your name and email directly from git config, so no personal information is hardcoded in the repository.

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
chezmoi cd
git add .
git commit -m "Update configuration"
git push
```
