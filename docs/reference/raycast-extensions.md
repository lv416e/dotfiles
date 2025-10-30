# Raycast Extensions

This document lists Raycast extensions currently in use. It serves as a reference for new machine setup.

## Configuration Management Strategy

- **Scripts**: Managed by chezmoi in `~/.config/raycast/scripts/`
- **Settings**: Synced via Raycast Cloud (not in version control)
- **Extensions**: Manual installation from Raycast Store

## Official Extensions

### Productivity
- **1Password** - Quick access to passwords and secure notes
- **GitHub** - Repository search, PR management, issue tracking
- **Brew** - Search and install Homebrew formulae/casks

### Development
- **Docker** - Container management and monitoring
- **File Search** - Advanced file search with preview
- **Window Management** - Keyboard-driven window tiling

## Community Extensions

(Add community extensions as you install them)

## Installation on New Machine

### Prerequisites
```bash
# Ensure Raycast is installed
brew install --cask raycast
```

### Extension Installation
1. Open Raycast (⌘ Space)
2. Search for "Store" or press ⌘,
3. Navigate to Extensions tab
4. Install required extensions from the list above

### Custom Scripts
Custom scripts are automatically deployed via chezmoi:
```bash
chezmoi apply
# Scripts will be available in ~/.config/raycast/scripts/
```

## Tips

- **Extension Updates**: Raycast auto-updates extensions by default
- **Cloud Sync**: Sign in to Raycast to sync settings across machines
- **Backup**: Settings are backed up to Raycast Cloud (no local backup needed)

## References

- [Raycast Store](https://www.raycast.com/store)
- [Raycast Documentation](https://manual.raycast.com/)
