# macOS System Preferences Automation

This guide explains how to automate macOS system preferences using the `defaults` command and chezmoi.

## Overview

macOS stores system preferences in property list (plist) files that can be modified using the `defaults` command. This dotfiles repository automates macOS system preferences to achieve near-perfect reproducibility across machines.

## Quick Start

### Discover Your Current Settings

```bash
# Extract current macOS system preferences
mise run sys-discover-settings
# or
mise discover

# Review the generated file
cat .chezmoitemplates/macos-defaults-discovered.sh
```

### Apply Settings

```bash
# Apply all dotfiles (includes macOS settings)
chezmoi apply

# Or specifically apply macOS settings
mise run sys-apply-settings
# or
mise apply-settings
```

## How It Works

### Architecture

The macOS defaults automation consists of three components:

1. **Extraction Script** (`scripts/extract-macos-defaults.sh`)
   - Discovers current macOS settings
   - Converts them to `defaults write` commands
   - Organizes by domain (Dock, Finder, etc.)

2. **Configuration Script** (`run_onchange_before_configure-macos.sh.tmpl`)
   - Applies macOS system preferences
   - Runs automatically when the file changes
   - Executed before other dotfiles are applied

3. **Mise Tasks** (in `~/.config/mise/config.toml`)
   - `sys-discover-settings` - Extract current settings
   - `sys-apply-settings` - Apply preferences

### Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Discover Settings                                    │
│    mise run sys-discover-settings                       │
│    ↓                                                     │
│    Generates: .chezmoitemplates/macos-defaults-         │
│               discovered.sh                             │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ 2. Review & Customize                                   │
│    - Review generated file                              │
│    - Remove unwanted settings                           │
│    - Add comments for clarity                           │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ 3. Add to Configuration                                 │
│    - Copy desired settings to:                          │
│      run_onchange_before_configure-macos.sh.tmpl        │
│    - Commit changes to git                              │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ 4. Apply Settings                                       │
│    chezmoi apply                                        │
│    ↓                                                     │
│    Automatically applies when file changes              │
└─────────────────────────────────────────────────────────┘
```

## Customizing Settings

### 1. Find Settings You Want

There are several ways to discover macOS settings:

#### Method 1: Use the Extraction Script

```bash
# Run extraction
mise run sys-discover-settings

# Review all extracted settings
cat .chezmoitemplates/macos-defaults-discovered.sh

# Search for specific domain
grep "com.apple.dock" .chezmoitemplates/macos-defaults-discovered.sh
```

#### Method 2: Manual Discovery

```bash
# View all settings for a domain
defaults read com.apple.dock

# View specific setting
defaults read com.apple.dock autohide

# List all domains
defaults domains
```

#### Method 3: Diff Before/After

```bash
# Save current state
defaults read > before.txt

# Change a setting in System Settings manually

# Save new state
defaults read > after.txt

# See what changed
diff before.txt after.txt
```

### 2. Add to Configuration

Edit `run_onchange_before_configure-macos.sh.tmpl`:

```bash
# ============================================================================
# Dock
# ============================================================================
echo "📦 Configuring Dock..."

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Set Dock icon size
defaults write com.apple.dock tilesize -int 48

# Don't show recent applications
defaults write com.apple.dock show-recents -bool false
```

### 3. Apply Changes

```bash
# Dry run to see what will execute
chezmoi apply --dry-run --verbose

# Apply changes
chezmoi apply

# Or use mise task
mise run sys-apply-settings
```

## Common Settings

### Dock

```bash
# Auto-hide Dock
defaults write com.apple.dock autohide -bool true

# Dock icon size (default: 48)
defaults write com.apple.dock tilesize -int 36

# Don't show recent applications
defaults write com.apple.dock show-recents -bool false

# Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Don't automatically rearrange Spaces
defaults write com.apple.dock mru-spaces -bool false
```

### Finder

```bash
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Use list view by default (icnv=icon, clmv=column, glyv=gallery, Nlsv=list)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable extension change warning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
```

### Screenshots

```bash
# Save to Pictures/Screenshots
defaults write com.apple.screencapture location -string "~/Pictures/Screenshots"

# Save as PNG (options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true
```

### Keyboard

```bash
# Blazingly fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 1

# Short delay until key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
```

### Trackpad

```bash
# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
```

## Data Types

The `defaults` command supports different data types:

```bash
# Boolean
defaults write domain key -bool true
defaults write domain key -bool false

# Integer
defaults write domain key -int 42

# Float
defaults write domain key -float 3.14

# String
defaults write domain key -string "value"

# Array
defaults write domain key -array "item1" "item2" "item3"

# Dictionary (complex - use plist editor)
defaults write domain key -dict key1 value1 key2 value2
```

## Testing Changes

### Before Applying

```bash
# Dry run
chezmoi apply --dry-run --verbose

# View what will execute
chezmoi cat run_onchange_before_configure-macos.sh.tmpl
```

### After Applying

```bash
# Verify specific setting
defaults read com.apple.dock autohide
# Expected: 1 (true) or 0 (false)

# Check if app needs restart
# Some settings require:
killall Dock
killall Finder
killall SystemUIServer

# Or logout/restart for full effect
```

### Backup & Restore

```bash
# Backup before testing
defaults export com.apple.dock ~/dock-backup.plist

# Test your changes
defaults write com.apple.dock autohide -bool true
killall Dock

# Restore if needed
defaults import com.apple.dock ~/dock-backup.plist
killall Dock
```

## Troubleshooting

### Settings Not Applied

```bash
# Check if script executed
chezmoi status

# Force re-run by clearing state
chezmoi state delete-bucket --bucket=scriptState

# Re-apply
chezmoi apply --force
```

### Settings Not Taking Effect

```bash
# Restart affected applications
killall Dock Finder SystemUIServer

# Or logout/login
# Some settings only take effect after logout

# Or reboot
# A few settings require full reboot
```

### Type Detection Issues

```bash
# Check actual type in plist
defaults read-type com.apple.dock autohide

# If extraction script gets type wrong, manually correct:
# Wrong:
defaults write com.apple.dock autohide -string "1"

# Correct:
defaults write com.apple.dock autohide -bool true
```

## Limitations

### What Can't Be Automated

**TCC (Transparency, Consent, and Control)** settings:
- Privacy & Security permissions
- Accessibility access
- Full Disk Access
- Screen Recording permissions
- Camera/Microphone access

These require manual granting through System Settings.

**SIP (System Integrity Protection)** restrictions:
- System-level modifications
- Certain security settings
- Protected system directories

**Version-specific settings**:
- Some settings may not exist in all macOS versions
- Settings may be deprecated or renamed between versions

### Workarounds

```bash
# Document manual steps in comments
# ============================================================================
# Manual Configuration Required
# ============================================================================
# - System Settings → Privacy & Security → Full Disk Access → Terminal
# - System Settings → Privacy & Security → Accessibility → Alacritty
```

## Advanced Usage

### Conditional Settings

Use chezmoi templates for conditional settings:

```bash
{{- if eq .chezmoi.hostname "work-mac" }}
# Work-specific settings
defaults write com.apple.dock autohide -bool false
{{- else }}
# Personal settings
defaults write com.apple.dock autohide -bool true
{{- end }}
```

### User Variables

```bash
# Use chezmoi variables
defaults write com.apple.screencapture location -string "{{ .chezmoi.homeDir }}/Pictures/Screenshots"

# Use prompted values
{{- $dockSize := promptInt . "dock_size" "Dock icon size (default: 48)" 48 }}
defaults write com.apple.dock tilesize -int {{ $dockSize }}
```

### Organizing by Category

```bash
# Create separate template files for different domains
# .chezmoitemplates/macos-dock.sh
# .chezmoitemplates/macos-finder.sh
# .chezmoitemplates/macos-keyboard.sh

# Include in main script
{{- template "macos-dock.sh" . }}
{{- template "macos-finder.sh" . }}
{{- template "macos-keyboard.sh" . }}
```

## Resources

### Official Documentation

- [defaults(1) man page](https://ss64.com/mac/defaults.html)
- [Property List Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/)

### Community Resources

- [macOS Defaults](https://macos-defaults.com/) - Searchable database
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) - Comprehensive `.macos` script
- [Advanced defaults Usage](https://shadowfile.inode.link/blog/2018/06/advanced-defaults1-usage/)

### Related Documentation

- [ADR-0009: macOS defaults automation strategy](../adr/0009-macos-defaults-automation.md)
- [Machine Setup Guide (macOS)](../getting-started/machine-setup-macos.md)
- [Mise Tasks Reference](../reference/mise-tasks-reference.md)

## Examples

### Complete Workflow Example

```bash
# 1. Extract current settings on your perfectly configured Mac
cd ~/.local/share/chezmoi
mise run sys-discover-settings

# 2. Review what was extracted
cat .chezmoitemplates/macos-defaults-discovered.sh | less

# 3. Edit the configuration script
# Copy desired settings from discovered file to:
$EDITOR run_onchange_before_configure-macos.sh.tmpl

# 4. Add comments to explain non-obvious settings
# 5. Remove any settings you don't want to version control

# 6. Test locally first
chezmoi apply --dry-run --verbose

# 7. Apply changes
chezmoi apply

# 8. Commit to git
chezmoi cd
git add run_onchange_before_configure-macos.sh.tmpl
git commit -m "feat: add macOS defaults automation"
git push

# 9. On new machine, settings apply automatically during:
chezmoi init --apply https://github.com/username/dotfiles.git
```

### Incremental Discovery Example

```bash
# Discover one domain at a time
defaults read com.apple.dock > dock-current.txt
defaults read com.apple.finder > finder-current.txt
defaults read NSGlobalDomain > global-current.txt

# Make changes in System Settings

# Compare
defaults read com.apple.dock > dock-new.txt
diff dock-current.txt dock-new.txt

# Add only the changed settings to your config
```

## See Also

<!-- TODO: - [Configuration Variants System](../explanation/configuration-variants.md) -->
- [Secrets Management Overview](./secrets-management-overview.md)
<!-- TODO: - [Troubleshooting Guide](../troubleshooting/README.md) -->
