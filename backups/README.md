# Zsh Configuration Backups

This directory contains backups of the original monolithic zsh configuration files.

## Backup Files

| File | Original File | Lines | Created | Description |
|------|--------------|-------|---------|-------------|
| `dot_zshrc.tmpl.monolithic` | `dot_zshrc.tmpl` | 476 | 2025-10-23 | Original monolithic .zshrc configuration |
| `dot_zshenv.tmpl.original` | `dot_zshenv.tmpl` | 12 | 2025-10-23 | Original .zshenv configuration (XDG-compliant bootstrap) |

## Backup Commit

```
f275dca Optimize tmux status bar and zsh startup performance
```

## Usage

### 1. Rollback

Restore the original configuration if issues arise with the modular setup.

```bash
# Restore original configuration
cd ~/.local/share/chezmoi
cp backups/dot_zshrc.tmpl.monolithic dot_zshrc.tmpl
cp backups/dot_zshenv.tmpl.original dot_zshenv.tmpl
chezmoi apply
exec zsh
```

### 2. Comparison

Compare new modular configuration with original setup.

```bash
# View differences
diff backups/dot_zshrc.tmpl.monolithic dot_zshrc.tmpl

# Compare with modular files
diff backups/dot_zshrc.tmpl.monolithic dot_config/zsh/dot_zshrc.tmpl
```

### 3. Reference

Reference specific configurations or implementations.

```bash
# Check alias definitions
grep "alias" backups/dot_zshrc.tmpl.monolithic | head -20

# Review function implementations
grep -A 10 "^repo()" backups/dot_zshrc.tmpl.monolithic
```

## Configuration Comparison

### Original (Monolithic)

```
dot_zshrc.tmpl (476 lines)
├── Performance Profiling
├── Core Initialization (Homebrew, Prompt)
├── Tool Configuration
├── Environment Variables
├── Aliases
├── Functions - Utilities
├── Functions - Shell Management
├── Functions - Repository Management
└── Completions
```

**Startup Time:** ~57ms

### Current (Modular)

```
dot_config/zsh/
├── dot_zshrc.tmpl (38 lines) - Module loader
└── conf.d/
    ├── 01-init.zsh (40 lines) - Core Initialization
    ├── 02-plugins.zsh (20 lines) - Plugin Management
    ├── 03-tools.zsh (40 lines) - Tool Configuration
    ├── 04-env.zsh (35 lines) - Environment Variables
    ├── 05-aliases.zsh (89 lines) - Aliases (deferred)
    ├── 06-functions.zsh (100 lines) - Functions (deferred)
    └── 07-repo.zsh (165 lines) - Repository Management (deferred)
```

**Startup Time:** 48.7ms (min), 55.1ms (avg) - **15% faster**

## Detailed Rollback Procedures

For comprehensive rollback instructions, refer to `docs/ZSH_ROLLBACK.md`.

### Quick Rollback

```bash
cd ~/.local/share/chezmoi
cp backups/dot_zshrc.tmpl.monolithic dot_zshrc.tmpl
cp backups/dot_zshenv.tmpl.original dot_zshenv.tmpl
git rm -r dot_config/zsh/
chezmoi apply
exec zsh
```

## Maintenance

### Do Not Modify Backups

These backup files represent a snapshot of the pre-modular configuration and should remain unchanged.

### Creating New Backups

For future configuration changes:

```bash
# Timestamped backup
cp dot_zshrc.tmpl backups/dot_zshrc.tmpl.$(date +%Y%m%d)

# Descriptive backup
cp dot_zshrc.tmpl backups/dot_zshrc.tmpl.before-major-change
```

## Related Documentation

- `docs/ZSH_ROLLBACK.md` - Detailed rollback procedures
- `docs/ZSH_MODULAR_CONFIG.md` - Modular configuration details
- `docs/NEW_MACHINE_SETUP.md` - New machine setup instructions

## Important Notes

1. **Retain this directory**: Ensures rollback capability
2. **Commit to Git**: Backup files managed by version control
3. **Cross-machine sync**: Available on all machines via chezmoi

## Git-Based Backup

chezmoi integrates with Git, providing additional backup layers:

```bash
# View commit history
git log --oneline --all -- dot_zshrc.tmpl

# View specific commit
git show f275dca:dot_zshrc.tmpl

# Restore from specific commit
git checkout f275dca -- dot_zshrc.tmpl
```

## Summary

This backup directory ensures:
- ✅ Always revertible to original configuration
- ✅ Comparison capabilities between old and new configurations
- ✅ Reference for original implementations
- ✅ Safe modular configuration testing

**Recommendation:** Maintain backup files permanently.
