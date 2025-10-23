# Mise Task Runner Guide

## Overview

This dotfiles repository includes a comprehensive set of **mise tasks** for automating common workflows. Tasks are defined in `~/.config/mise/config.toml` and can be run with:

```bash
mise <task-name>
# or
mise run <task-name>
```

## Quick Reference

### List All Tasks
```bash
mise tasks
```

### Run with Alias
```bash
mise up      # Same as: mise sys-update
mise a       # Same as: mise dot-apply
mise ops     # Same as: mise op-signin
```

## Task Categories

### 🔧 System Maintenance (`sys-*`)

#### `mise sys-update` (alias: `up`)
Update all mise-managed tools and prune old versions.
```bash
mise sys-update
```

#### `mise sys-clean` (alias: `c`)
Clean all caches (sheldon, zsh completion, mise).
```bash
mise sys-clean
```

#### `mise sys-check` (alias: `chk`)
Verify mise installation and configuration.
```bash
mise sys-check
```

#### `mise sys-health` (alias: `h`)
Run comprehensive health checks (mise, Homebrew, chezmoi).
```bash
mise sys-health
```

#### `mise sys-status` (alias: `st`)
Show system status including installed tools and cache sizes.
```bash
mise sys-status
```

#### `mise sys-bench` (alias: `b`)
Benchmark zsh startup time (10 runs).
```bash
mise sys-bench
```

### 📦 Dotfiles Management (`dot-*`)

#### `mise dot-apply` (alias: `a`)
Apply dotfiles to system.
```bash
mise dot-apply
```

#### `mise dot-backup` (alias: `bak`)
Push dotfiles to remote repository.
```bash
mise dot-backup
```

#### `mise dot-status` (alias: `s`)
Show git status of dotfiles repository.
```bash
mise dot-status
```

#### `mise dot-diff` (alias: `d`)
Show diff between source and applied dotfiles.
```bash
mise dot-diff
```

### 🔐 1Password Tasks (`op-*`)

#### `mise op-signin` (alias: `ops`)
Sign in to 1Password.
```bash
mise op-signin
# Then authenticate in browser or enter password
```

**Important**: This sets up your 1Password session for other tasks and chezmoi templates.

#### `mise op-status` (alias: `opst`)
Check 1Password authentication status.
```bash
mise op-status
# Output: Signed in or "Not signed in"
```

#### `mise op-vaults` (alias: `opv`)
List all vaults in your 1Password account.
```bash
mise op-vaults
```

Example output:
```
ID                            NAME
2gbbdexcgduokl6qesengzi3cm    Personal
```

#### `mise op-items` (alias: `opi`)
List all items in Personal vault.
```bash
mise op-items
```

#### `mise op-get` (alias: `opg`)
Get details for a specific item.
```bash
mise op-get "API Keys"
mise op-get "GitHub Token"
```

### 🔒 Secrets Management (`secrets-*`)

#### `mise secrets-verify` (alias: `sv`)
Verify age and 1Password setup.
```bash
mise secrets-verify
```

Example output:
```
=== Age Key Status ===
✅ Age key exists: ~/.config/chezmoi/key.txt
Public key: age14t9x0zwv2adeujgjryk33s4f7wcxmsn7y7ws65hz7fs80fw9rfeqk8a4rg

=== 1Password Status ===
✅ Signed in to 1Password

=== Chezmoi Encryption Config ===
encryption = "age"
```

#### `mise secrets-test` (alias: `st`)
Test 1Password template integration.
```bash
mise secrets-test
```

Shows available vaults and provides example command for testing secret retrieval.

#### `mise secrets-list` (alias: `sl`)
List age-encrypted files managed by chezmoi.
```bash
mise secrets-list
```

#### `mise secrets-add` (alias: `sa`)
Add a file with age encryption.
```bash
mise secrets-add ~/.aws/credentials
mise secrets-add ~/.kube/config
mise secrets-add ~/.ssh/id_rsa
```

These files are automatically encrypted and can be safely committed to git.

### 🛠️ Tool Management (`tool-*`)

#### `mise tool-install` (alias: `i`)
Install all tools from configuration.
```bash
mise tool-install
```

#### `mise tool-outdated` (alias: `out`)
Check for outdated tools.
```bash
mise tool-outdated
```

### 🔄 Workflows (Complex Operations)

#### `mise sync` (alias: `sy`)
Full synchronization: apply → update → clean.
```bash
mise sync
```

**Runs in sequence**:
1. `dot-apply` - Apply latest dotfiles
2. `sys-update` - Update all tools
3. `sys-clean` - Clean caches

#### `mise fresh` (alias: `f`)
Fresh start: clean → apply → update.
```bash
mise fresh
```

Perfect for after pulling dotfiles changes from git.

## Common Workflows

### Daily Workflow
```bash
# Morning: Check status
mise sys-status
mise op-status

# Work with secrets (if needed)
mise op-signin
mise secrets-verify

# Update everything
mise sync
```

### Adding New Secrets

#### Option 1: 1Password (for API tokens)
```bash
# 1. Add secret to 1Password via app or CLI
op item create --category=login --title="OpenAI API" \
  --vault=Personal \
  credential="sk-..."

# 2. Use in template (e.g., ~/.zshenv.tmpl)
# export OPENAI_API_KEY="{{ onepasswordRead "op://Personal/OpenAI API/credential" }}"

# 3. Apply
mise dot-apply
```

#### Option 2: age Encryption (for large files)
```bash
# Add encrypted file
mise secrets-add ~/.aws/credentials

# Verify
mise secrets-list

# Apply
mise dot-apply
```

### Troubleshooting Secrets

```bash
# 1. Verify setup
mise secrets-verify

# 2. Check 1Password auth
mise op-status

# If not signed in:
mise op-signin

# 3. Test template
chezmoi execute-template '{{ onepasswordRead "op://Personal/API Keys/password" }}'

# 4. Check encrypted files
mise secrets-list
```

### Performance Benchmarking

```bash
# Before optimization
mise sys-bench

# Make changes...

# After optimization
mise sys-bench

# Compare results
```

## Task Chaining

Tasks can depend on other tasks:

```bash
# 'sync' runs: dot-apply → sys-update → sys-clean
mise sync

# 'fresh' runs all tasks sequentially
mise fresh
```

## Creating Custom Tasks

Edit `~/.config/mise/config.toml`:

```toml
[tasks.my-task]
description = "My custom task"
alias = "mt"
run = "echo 'Hello from my task'"

[tasks.complex-task]
description = "Multi-step task"
depends = ["sys-clean", "dot-apply"]
run = [
  "echo 'Step 1'",
  "echo 'Step 2'",
  "echo 'Step 3'",
]
```

## Tips

### Use Aliases for Speed
```bash
mise up    # instead of: mise sys-update
mise a     # instead of: mise dot-apply
mise ops   # instead of: mise op-signin
```

### Check Task Details
```bash
mise task info <task-name>
```

### Run Multiple Tasks
```bash
mise sys-clean dot-apply sys-update
```

### Background Execution
```bash
mise sys-update &
```

### Dry Run (for some tasks)
```bash
chezmoi apply --dry-run  # via: mise dot-apply with --dry-run flag
```

## Integration with Other Tools

### GitHub Actions
Tasks can be run in CI/CD:
```yaml
- name: Verify dotfiles
  run: |
    mise sys-check
    mise secrets-verify
```

### Shell Scripts
```bash
#!/bin/bash
mise sys-clean
mise dot-apply
mise sys-update
```

### Cron Jobs
```bash
# Update tools daily at 2am
0 2 * * * cd ~ && mise sys-update
```

## Troubleshooting

### Task Not Found
```bash
# List all tasks
mise tasks

# Check config syntax
mise config ls
```

### Permission Denied
```bash
# Some tasks may need sudo
sudo mise sys-clean
```

### 1Password Session Expired
```bash
# Re-authenticate
mise op-signin
```

### Age Decryption Failed
```bash
# Verify key exists
ls -la ~/.config/chezmoi/key.txt

# Check permissions
chmod 600 ~/.config/chezmoi/key.txt

# Verify config
mise secrets-verify
```

## References

- [mise Documentation](https://mise.jdx.dev/)
- [mise Tasks Guide](https://mise.jdx.dev/tasks/)
- [1Password CLI](https://developer.1password.com/docs/cli/)
- [age Encryption](https://github.com/FiloSottile/age)
