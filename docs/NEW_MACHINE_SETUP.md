# New Machine Setup Guide

This guide explains how to set up a new macOS machine with this dotfiles repository.

## Prerequisites

1. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Configure Git identity**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

## Installation

### 1. Install chezmoi and initialize dotfiles

```bash
# Install chezmoi
brew install chezmoi

# Initialize with your dotfiles repository (DO NOT use --apply yet)
chezmoi init https://github.com/YOUR_USERNAME/dotfiles.git
```

**Important**: Do NOT use `--apply` flag yet if you have encrypted files or 1Password secrets. We need to set up encryption first.

### 2. Set up secrets management (CRITICAL)

This repository uses **two methods** for secrets management:
- **age encryption** for encrypted files (e.g., SSH keys, AWS credentials)
- **1Password CLI** for API tokens in templates (e.g., `.zshenv.tmpl`)

You MUST complete this section before applying dotfiles, otherwise `chezmoi apply` will fail.

#### Option A: Restore age private key from existing machine (Recommended)

If you have the age private key from your old machine:

```bash
# 1. Install age
brew install age

# 2. Copy the private key from your old machine
# OLD MACHINE:
scp ~/.config/chezmoi/key.txt username@new-machine:~/key.txt.backup

# NEW MACHINE:
mkdir -p ~/.config/chezmoi
mv ~/key.txt.backup ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt

# 3. Verify the key
grep "AGE-SECRET-KEY" ~/.config/chezmoi/key.txt
# Should output: AGE-SECRET-KEY-1...
```

#### Option B: Generate new age key (Fresh start)

If you don't have the old key (or this is your first setup):

```bash
# 1. Install age
brew install age

# 2. Generate new age key
chezmoi age-keygen --output ~/.config/chezmoi/key.txt

# 3. Save the public key that was printed
# Example output:
# Public key: age14t9x0zwv2adeujgjryk33s4f7wcxmsn7y7ws65hz7fs80fw9rfeqk8a4rg

# 4. Update .chezmoi.toml.tmpl with the new public key
# Edit: ~/.local/share/chezmoi/.chezmoi.toml.tmpl
# Replace the recipient line with your new public key
```

**Warning**: If you generate a new key, you won't be able to decrypt files encrypted with the old key. You'll need to re-encrypt all secret files.

#### Set up 1Password CLI

If your dotfiles use `onepasswordRead` template function:

```bash
# 1. Install 1Password CLI
brew install --cask 1password-cli

# 2. Sign in to 1Password
op signin

# 3. Verify authentication
op whoami
# Should show your 1Password account email

# 4. List vaults to confirm access
op vault list
# Should show at least "Personal" vault

# 5. Test secret retrieval (optional)
op item list --vault Personal
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

# Should show:
# ✅ Age key exists
# ✅ Signed in to 1Password
# ✅ Age encryption configured in chezmoi
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
  --title="Chezmoi Age Key" \
  --vault=Personal \
  notesPlain="$(cat ~/.config/chezmoi/key.txt)"

# Retrieve on new machine
op item get "Chezmoi Age Key" --fields notesPlain --vault Personal > ~/.config/chezmoi/key.txt
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

## Notes

- The tmux status bar updates every 15 seconds
- Claude usage data is cached for 60 seconds to minimize API calls
- Scripts use background updates to prevent blocking tmux refresh
- First run may take 2-5 seconds to fetch Claude usage data
- **IMPORTANT**: Always back up your age private key before setting up new machines
