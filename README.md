# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/)

## Fresh Setup

### Prerequisites

These dotfiles dynamically retrieve your name and email from git config.
First, configure your git credentials:

```sh
git config --global user.name "your-name"
git config --global user.email "your-email@example.com"
```

### Installation

```sh
chezmoi init --apply lv416e/dotfiles
```

## Usage on Existing Environment

### Edit configuration

```sh
chezmoi edit ~/.zshrc
```

### Apply changes

```sh
chezmoi apply
```

### Commit and push changes

```sh
chezmoi cd
git add .
git commit -m "Update configuration"
git push
```
