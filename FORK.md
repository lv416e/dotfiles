# Fork Guide

This repository is designed to be fork-friendly with **zero manual configuration required**. Everything is handled through interactive prompts.

## Quick Fork

```bash
# 1. Fork on GitHub (click "Fork" button)

# 2. Install prerequisites
brew install chezmoi age 1password-cli

# 3. Configure git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 4. Initialize (interactive prompts appear)
chezmoi init YOUR_USERNAME/dotfiles

# 5. Apply
chezmoi apply -v

# 6. Install packages
cd ~/.local/share/chezmoi
brew bundle install
mise install
mise trust
```

## What You'll Be Asked

During `chezmoi init`, you'll answer these questions **once**:

### Basic Information
- **Email address** - For git commits (default: from git config)
- **GitHub username** - For repository references (optional)

### Secrets Management (Optional)
- **1Password vault name** - Vault for secrets (default: "Personal")
- **Use GitHub token from 1Password?** - Fetch token from 1Password (default: No)
- **1Password item name** - Item containing GitHub token (default: "GitHub Classic PAT")
- **Enable age encryption?** - For encrypting sensitive files (default: No)
- **Age public key** - Your age recipient key (required if age enabled)

### Preferences
- **Zsh config style** - "monolithic" (single file) or "modular" (multiple files) (default: monolithic)
- **Terminal multiplexer** - "tmux" or "zellij" (default: tmux)
- **Enable difftastic?** - Enhanced git diff (default: Yes)

## Your answers are saved in `~/.config/chezmoi/chezmoi.toml`

You won't be prompted again unless you delete this file. To change answers:

```bash
$EDITOR ~/.config/chezmoi/chezmoi.toml
chezmoi apply
```

## Optional Features

### 1Password Integration

If you answered "Yes" to using GitHub token from 1Password:

```bash
# Sign in to 1Password
op signin

# Create the GitHub token item
op item create \
  --category="API Credential" \
  --title="GitHub Classic PAT" \
  --vault=Personal \
  credential="ghp_YOUR_TOKEN_HERE"

# Verify
mise secrets-verify
```

> [!NOTE]
> Don't have 1Password? No problem! Just answer "No" to the 1Password questions. The setup works perfectly without it.

### Age Encryption

If you answered "Yes" to age encryption:

```bash
# Generate age key
chezmoi age-keygen --output ~/.config/chezmoi/key.txt

# The output shows your public key (starts with age1...)
# Copy this value - you'll paste it when prompted

# Backup your key to 1Password (highly recommended!)
mise secrets-age-key-backup

# Add encrypted files
chezmoi add --encrypt ~/.ssh/id_rsa
chezmoi add --encrypt ~/.aws/credentials
```

> [!NOTE]
> Don't need encryption? Answer "No" and skip this entirely.

## Verification

After setup, verify everything works:

```bash
# Check secrets configuration
mise secrets-verify
```

> [!TIP]
> Expected output from `mise secrets-verify`:
> - Age Key Status: Age key exists at `~/.config/chezmoi/key.txt` (if enabled)
> - 1Password Status: Signed in to 1Password (if used)
> - Chezmoi Encryption Config: `encryption = "age"` (if enabled)

```bash
# Test shell
exec zsh

# Verify mise tasks work
mise tasks

# Check tmux status bar
tmux
# Status bar should show: Claude usage, CPU, RAM, battery
```

## Customization

### Modify Your Configuration

```bash
# View your configuration
cat ~/.config/chezmoi/chezmoi.toml

# Edit any value
$EDITOR ~/.config/chezmoi/chezmoi.toml

# Re-apply
chezmoi apply
```

### Add Personal Customizations

```bash
# Edit existing dotfiles
chezmoi edit ~/.zshrc
chezmoi apply

# Add new dotfiles
chezmoi add ~/.myconfig
```

### Commit Your Changes

```bash
chezmoi cd
git add .
git commit -m "Customize for my setup"
git push
```

## Differences from Original Repository

When you fork this repository, **everything just works** without manual edits:

| Original Workflow | Your Workflow |
|-------------------|---------------|
| Edit `.chezmoi.toml.tmpl` manually | Answer prompts |
| Update vault name in 10+ files | Specify once in prompt |
| Update age key in config | Paste when prompted |
| Create 1Password items manually | Optional, with clear instructions |
| Hope everything works | Verify with `mise secrets-verify` |

## Troubleshooting

### Prompts Don't Appear

```bash
# Delete saved configuration
rm ~/.config/chezmoi/chezmoi.toml

# Re-initialize
chezmoi init YOUR_USERNAME/dotfiles
```

### 1Password Errors

```bash
# Check authentication
op whoami

# Sign in if needed
op signin

# Verify vault exists
op vault list

# Check item exists
op item get "GitHub Classic PAT" --vault Personal
```

### Age Encryption Errors

```bash
# Verify key exists
ls -la ~/.config/chezmoi/key.txt

# Should show: -rw------- (600 permissions)

# Fix permissions if needed
chmod 600 ~/.config/chezmoi/key.txt

# Verify public key matches
age-keygen -y ~/.config/chezmoi/key.txt
# Compare with recipient in ~/.config/chezmoi/chezmoi.toml
```

### Reset Everything

```bash
# Remove chezmoi configuration
rm -rf ~/.local/share/chezmoi ~/.config/chezmoi

# Start fresh
chezmoi init YOUR_USERNAME/dotfiles
```

## FAQ

**Q: Do I need 1Password?**
A: No! When prompted, answer "No" to 1Password questions. The setup works perfectly with just environment variables.

**Q: Do I need age encryption?**
A: No! It's optional. Only enable if you want to store encrypted files in your dotfiles repository.

**Q: Can I change my answers later?**
A: Yes! Edit `~/.config/chezmoi/chezmoi.toml` and run `chezmoi apply`.

**Q: What if I skip a prompt?**
A: Press Enter to accept the default value. You can always change it later.

**Q: How do I update my fork with upstream changes?**
A:
```bash
cd ~/.local/share/chezmoi
git remote add upstream https://github.com/lv416e/dotfiles.git
git fetch upstream
git merge upstream/main
git push
```

**Q: Can I use this on Linux?**
A: Yes! Most features work on Linux. Some macOS-specific tools will be skipped automatically.

**Q: Where can I get help?**
A:
- Check [New Machine Setup Guide](docs/getting-started/new-machine-setup.md)
- Review [Troubleshooting section](docs/getting-started/new-machine-setup.md#troubleshooting)
- Open an issue on GitHub

## What's Next?

After successful setup:

1. **Explore mise tasks**: `mise tasks`
2. **Read the documentation**: Check `docs/` directory
3. **Customize**: Start tweaking configs to match your preferences
4. **Enjoy**: You now have a modern, well-organized dotfiles setup!

## Contributing Back

Found a bug or improvement? Pull requests welcome!

```bash
cd ~/.local/share/chezmoi
git checkout -b my-improvement
# Make changes
git commit -am "Describe your improvement"
git push origin my-improvement
# Open PR on GitHub
```
