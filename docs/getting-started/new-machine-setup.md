# New Machine Setup Guide

This guide explains how to set up a new macOS machine with this dotfiles repository.

## Quick Start (Recommended)

For most users, the **interactive setup** is the easiest way to get started:

```bash
# 1. Install prerequisites
brew install chezmoi age 1password-cli

# 2. Configure git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 3. Initialize (you'll be prompted for configuration)
chezmoi init YOUR_USERNAME/dotfiles

# 4. Apply dotfiles
chezmoi apply -v

# 5. Install packages
cd ~/.local/share/chezmoi
brew bundle install
mise install
mise trust

# 6. Verify setup
mise secrets-verify
```

During step 3, you'll answer questions about your preferences. **No manual file editing required!**

See [Fork Guide](../../FORK.md) for detailed walkthrough.

## Prerequisites

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Note**: The Homebrew installation script automatically installs Xcode Command Line Tools if not already present. You don't need to run `xcode-select --install` separately.

### 2. Configure Git Identity

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Interactive Setup

### What You'll Be Asked

When you run `chezmoi init`, you'll be prompted for:

| Prompt | Description | Default | Required |
|--------|-------------|---------|----------|
| Email address | Your email | From git config | Yes |
| GitHub username | For repository refs | (empty) | No |
| 1Password vault | Vault for secrets | "Personal" | No |
| Use GitHub token? | Fetch from 1Password | No | No |
| GitHub token item | 1Password item name | "GitHub Classic PAT" | If above is Yes |
| Enable age encryption? | For encrypted files | No | No |
| Age public key | Your recipient key | (empty) | If above is Yes |
| Zsh config style | monolithic/modular | monolithic | No |
| Terminal multiplexer | tmux/zellij | tmux | No |
| Enable difftastic? | Git diff tool | Yes | No |

### Your Answers Are Saved

Answers are stored in `~/.config/chezmoi/chezmoi.toml`. You won't be prompted again unless you delete this file.

To change answers later:

```bash
$EDITOR ~/.config/chezmoi/chezmoi.toml
chezmoi apply
```

## Optional: Advanced Secrets Setup

The interactive setup handles basic configuration. If you need advanced secrets management:

### Age Encryption (Optional)

Only needed if you answered "Yes" to age encryption:

```bash
# Generate age key
chezmoi age-keygen --output ~/.config/chezmoi/key.txt

# Copy the public key from the output (starts with age1...)
# You'll paste this when prompted during chezmoi init

# Backup your key (highly recommended!)
mise secrets-age-key-backup
```

**Restoring existing key:**

```bash
# From 1Password
mise secrets-age-key-restore

# Or from backup
scp old-machine:~/.config/chezmoi/key.txt ~/.config/chezmoi/
chmod 600 ~/.config/chezmoi/key.txt
```

### 1Password Integration (Optional)

Only needed if you answered "Yes" to using GitHub token from 1Password:

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
mise op-status
```

## Verification (Important!)

After setup, verify everything is configured correctly:

```bash
# Run comprehensive verification
mise secrets-verify
```

> [!TIP]
> Expected output from `mise secrets-verify`:
> - Age Key Status: Age key exists at `~/.config/chezmoi/key.txt`
> - 1Password Status: Signed in to 1Password
> - Chezmoi Encryption Config: `encryption = "age"`
>
> If all checks pass, your setup is complete!

### Additional Verification

```bash
# Test shell configuration
exec zsh
# Should load without errors

# Verify mise tasks
mise tasks
# Should list 24 available tasks

# Check tmux status bar
tmux
# Status bar should display: Claude usage, CPU, RAM, battery

# Test chezmoi
chezmoi status
# Should show no differences if all applied correctly
```
```

**Important**: You must complete `op signin` and authenticate via browser before running `chezmoi apply`, otherwise templates with `onepasswordRead` will fail.

#### Verify secrets setup

```bash
# Check age key
ls -l ~/.config/chezmoi/key.txt
# Should show: -rw------- (600 permissions)

# Check 1Password authentication
op whoami
# Should show your email

# Test chezmoi configuration
chezmoi init
# Should complete without errors
```

### 4. Apply dotfiles (Now it's safe!)

After secrets are configured, you can now apply dotfiles:

```bash
# Apply all dotfiles
chezmoi apply -v

# If there are any errors, check the output carefully
# Most common issues are related to missing secrets or incorrect key
```

### 5. Install Homebrew packages

```bash
# Navigate to dotfiles directory
cd ~/.local/share/chezmoi

# Install all Homebrew packages defined in Brewfile
brew bundle install
```

### 6. Install development tools with mise

```bash
# Mise should already be installed from Brewfile
# Install all tools defined in mise config
mise install

# Verify installation
mise ls
```

### 7. Set up tmux plugins

```bash
# Start tmux
tmux

# Inside tmux, press: Prefix (Ctrl+g) + I
# This will install all tmux plugins defined in .tmux.conf
```

### 8. Verify tmux status bar

The status bar should display:
- Claude Code usage and cost (CLD:X.XM/$X.XX)
- CPU usage (CPU:XX%)
- RAM usage (RAM:X.XG)
- Battery status (CHG/BAT/AC:XX%)
- Date and time

If Claude usage shows "CLD:N/A":
1. Ensure ccusage is installed: `which ccusage`
2. Try running: `ccusage --today`
3. Check logs: `cat /tmp/tmux-claude-usage.err`

## Dependencies for tmux Status Bar

All required dependencies are automatically installed:

### From Brewfile:
- `jq` - JSON parsing

### From mise config.toml:
- `npm:ccusage` - Claude Code usage tracker

### macOS built-in:
- `iostat` - CPU monitoring
- `vm_stat` - RAM monitoring
- `pmset` - Battery monitoring
- `timeout` - Command timeout utility

## Troubleshooting

### Secrets Management Issues

#### `chezmoi apply` fails with age decryption error

**Error**: `chezmoi: cannot decrypt "..." with age: failed to decrypt`

**Solutions**:
1. Verify age key exists and has correct permissions:
   ```bash
   ls -l ~/.config/chezmoi/key.txt
   # Should show: -rw------- (600 permissions)

   # Fix permissions if needed:
   chmod 600 ~/.config/chezmoi/key.txt
   ```

2. Verify you have the correct age key:
   ```bash
   # Extract public key from private key
   age-keygen -y ~/.config/chezmoi/key.txt

   # Compare with recipient in .chezmoi.toml.tmpl
   grep recipient ~/.local/share/chezmoi/.chezmoi.toml.tmpl
   ```

3. If public keys don't match, you have the wrong private key. Options:
   - Restore correct key from backup
   - Generate new key and re-encrypt all secret files

#### `chezmoi apply` fails with 1Password error

**Error**: `could not read secret 'op://...': "vault" isn't a vault in this account`

**Solutions**:
1. Verify 1Password authentication:
   ```bash
   op whoami
   # Should show your email

   # If not signed in:
   op signin
   ```

2. Check vault name is correct:
   ```bash
   op vault list
   # Verify the vault name matches what's in your templates
   ```

3. Test secret retrieval manually:
   ```bash
   # Replace with actual secret path from your template
   op item get "API Keys" --vault Personal
   ```

4. Re-authenticate if session expired:
   ```bash
   op signin --force
   ```

#### Age key lost or corrupted

If you lost your age private key and cannot decrypt existing secrets:

**Option 1**: Restore from backup
```bash
# If you backed up the key
cp /path/to/backup/key.txt ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
```

**Option 2**: Generate new key and re-encrypt (DESTRUCTIVE)
```bash
# 1. Backup encrypted files first
chezmoi managed | grep -E '\.age$' > encrypted_files.txt

# 2. Generate new age key
chezmoi age-keygen --output ~/.config/chezmoi/key.txt

# 3. Update .chezmoi.toml.tmpl with new public key
# Edit recipient line with output from step 2

# 4. Re-add all encrypted files
# You'll need to have unencrypted copies from old machine
while read file; do
  chezmoi add --encrypt "$file"
done < encrypted_files.txt
```

#### Template variable not found

**Error**: `template: ... undefined variable "..."`

**Solution**: Ensure git config is set up (chezmoi uses git user.name and user.email):
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Regenerate config
chezmoi init
```

#### Verify complete secrets setup

Run comprehensive check:
```bash
# Install mise first (from Brewfile)
brew bundle install

# Then run secrets verification
mise secrets-verify

# Expected output:
# - Age key exists
# - Signed in to 1Password
# - Age encryption configured in chezmoi
```

### ccusage not found

If `ccusage` is not in PATH after mise installation:
```bash
# Activate mise in current shell
eval "$(mise activate zsh)"

# Or add to .zshrc (should already be there):
eval "$(mise activate zsh)"
```

### tmux status bar shows N/A

1. Check if scripts are executable:
   ```bash
   ls -l ~/.local/bin/tmux-*.sh
   ```

2. Test each script individually:
   ```bash
   ~/.local/bin/tmux-claude-usage.sh
   ~/.local/bin/tmux-cpu-usage.sh
   ~/.local/bin/tmux-ram-usage.sh
   ~/.local/bin/tmux-battery.sh
   ```

3. Clear cache and retry:
   ```bash
   rm /tmp/tmux-*-usage.cache
   tmux refresh-client -S
   ```

### Scripts have no execute permission

```bash
cd ~/.local/share/chezmoi
chezmoi apply --force
```

## Post-Installation

1. **Reload shell**:
   ```bash
   exec zsh
   ```

2. **Verify shell performance**:
   ```bash
   mise run sys-bench
   # or
   zsh-bench
   ```

3. **Test tmux setup**:
   ```bash
   tmux new -s test
   # Check if status bar displays correctly
   ```

## Best Practices for Secrets Management

### Backing up your age private key

**CRITICAL**: The age private key is the ONLY way to decrypt your encrypted files. If you lose it, you CANNOT recover your encrypted data.

#### Option 1: Secure cloud backup (Recommended)

Store in 1Password as a secure note:
```bash
# Create secure note with age key
op item create --category="Secure Note" \
  --title="chezmoi-age-key" \
  --vault=Personal \
  notesPlain="$(cat ~/.config/chezmoi/key.txt)"

# Retrieve on new machine
op item get "chezmoi-age-key" --fields notesPlain --vault Personal > ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
```

#### Option 2: Encrypted USB backup

```bash
# Encrypt the key with a strong passphrase
age --passphrase --output ~/age-key.enc ~/.config/chezmoi/key.txt

# Copy to USB drive
cp ~/age-key.enc /Volumes/USB/backups/

# Restore on new machine
age --decrypt ~/age-key.enc > ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
```

#### Option 3: Print as QR code (Air-gap backup)

```bash
# Generate QR code (requires qrencode)
brew install qrencode
cat ~/.config/chezmoi/key.txt | qrencode -t PNG -o ~/age-key-qr.png

# Print and store in safe place
open ~/age-key-qr.png
# Print, then delete file

# Restore from QR code (requires zbar-tools)
brew install zbar
zbarimg -q --raw ~/scanned-qr.png > ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
```

### Maintenance checklist

After setting up a new machine:

- [ ] Age key restored and verified
- [ ] 1Password authenticated (`op whoami` works)
- [ ] All encrypted files decrypt successfully
- [ ] Environment variables with secrets load correctly
- [ ] `mise secrets-verify` passes all checks
- [ ] Backup of age key stored in 1Password or secure location

## Quick Start Summary

For experienced users who already have the age key and 1Password set up:

```bash
# 1. Install prerequisites
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 2. Install chezmoi and initialize
brew install chezmoi
chezmoi init https://github.com/YOUR_USERNAME/dotfiles.git

# 3. Set up secrets
brew install age 1password-cli
mkdir -p ~/.config/chezmoi
# Restore age key here (see backup section above)
op signin

# 4. Apply dotfiles
chezmoi apply -v

# 5. Install packages
cd ~/.local/share/chezmoi
brew bundle install
mise install

# 6. Done! Verify
mise secrets-verify
```

## Cloud Development Environments (DevContainer/Codespaces)

This repository includes a DevContainer configuration for GitHub Codespaces and local DevContainer development. Dotfiles are automatically applied when you create a Codespace or open the repository in a DevContainer.

### Quick Start with GitHub Codespaces

1. **Create a Codespace**:
   - Navigate to the repository on GitHub
   - Click "Code" → "Codespaces" → "Create codespace on main"
   - Wait 5-10 minutes for initial setup (includes dotfiles application)

2. **Verify Setup**:
   ```bash
   # Check shell configuration
   echo $SHELL
   # Should output: /bin/zsh

   # Verify mise tools
   mise list
   # Should show installed tools

   # Test development tools
   which git gh fzf bat eza
   # All should be found in PATH
   ```

3. **Start Developing**:
   - Your personal zsh configuration is already active
   - All CLI tools (fzf, bat, eza, gitui, etc.) are installed
   - VS Code extensions are pre-installed

### DevContainer on Local Machine

**Prerequisites**:
- Docker Desktop or OrbStack installed
- VS Code with "Dev Containers" extension

**Usage**:
1. Open repository in VS Code
2. Press `⌘⇧P` → "Dev Containers: Reopen in Container"
3. Wait for container build and dotfiles application
4. Start coding in your familiar environment

### Linux Environment Limitations

DevContainers run on Ubuntu Linux. Due to the best-effort Linux support strategy (see [ADR-0008](../adr/0008-linux-best-effort-support.md)):

| Component | Status | Notes |
|-----------|--------|-------|
| **Shell (zsh)** | ✅ Full | Complete zsh configuration with all plugins |
| **CLI Tools** | ✅ Full | All 102 Homebrew formulae work (mise, fzf, bat, eza, etc.) |
| **Git Config** | ✅ Full | Difftastic, Jujutsu, all git aliases functional |
| **Secrets** | ⚠️ Partial | age encryption works; 1Password CLI works but no GUI app |
| **GUI Apps** | ❌ Skip | All 25 macOS casks silently excluded (Raycast, Hammerspoon, etc.) |
| **Terminal Emulators** | ❌ Skip | Alacritty/Kitty/Ghostty configs present but apps not installed |

**Expected Warnings**:
During dotfiles application, you may see:
```
⚠️  Dotfiles application encountered errors (expected on Linux - casks skipped)
```

This is **normal and expected**. The errors are from macOS-specific casks being excluded. Core development functionality is fully operational.

### What Works in DevContainers

**Development Workflow**:
- ✅ Fast shell startup (~45ms with zsh-defer)
- ✅ mise version management (Node, Python, Rust, Go)
- ✅ Modern CLI tools (gitui, bottom, dust, fd, ripgrep)
- ✅ Git workflow with difftastic and Jujutsu
- ✅ fzf-powered fuzzy finding
- ✅ Syntax highlighting (bat) and modern ls (eza)
- ✅ All zsh aliases and functions

**VS Code Integration**:
- ✅ 26 pre-installed extensions (Python, Go, Rust, etc.)
- ✅ Terminal defaults to zsh with your config
- ✅ mise-managed tool paths configured
- ✅ Chezmoi extension for dotfiles editing

### Port Forwarding

The DevContainer automatically forwards common development ports:

| Port | Purpose | Auto-forward Behavior |
|------|---------|----------------------|
| 3000 | Frontend (React/Next.js) | Notify on forward |
| 5000 | Backend (Flask/FastAPI) | Notify on forward |
| 8000 | Development Server | Notify on forward |
| 8080 | Alternative HTTP | Notify on forward |

### Troubleshooting DevContainers

**Dotfiles failed to apply**:
```bash
# Check chezmoi installation
which chezmoi
# Should output: /usr/local/bin/chezmoi

# Manually re-apply
chezmoi init --apply lv416e

# Check status
chezmoi status
```

**Tools not in PATH**:
```bash
# Reload shell
exec zsh

# Verify mise activation
mise doctor
```

**Performance concerns**:
- Initial setup takes 5-10 minutes (one-time cost)
- Subsequent rebuilds are faster (~2-3 minutes)
- Consider using "Dev Containers: Rebuild Container" sparingly

### When to Use DevContainers

**Good for**:
- Quick experiments without affecting local machine
- Consistent team development environments
- Testing Linux compatibility
- Development on non-macOS machines (Windows, ChromeOS)

**Not ideal for**:
- GUI-heavy workflows (window management, Raycast automation)
- macOS-specific app development (Hammerspoon scripts)
- When you need macOS-specific tools

## Notes

- The tmux status bar updates every 15 seconds
- Claude usage data is cached for 60 seconds to minimize API calls
- Scripts use background updates to prevent blocking tmux refresh
- First run may take 2-5 seconds to fetch Claude usage data
- **IMPORTANT**: Always back up your age private key before setting up new machines
