# DevContainer Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: `git config user.email: exit status 1`

#### Symptoms
```
chezmoi: template: chezmoi.toml:21:77: executing "chezmoi.toml" at <output "git" "config" "user.email">: error calling output: /usr/local/bin/git config user.email: exit status 1
[ERROR] Failed to initialize dotfiles
```

#### Root Cause
- Git configuration is not set within the container environment
- Template file `.chezmoi.toml.tmpl` fails when attempting to retrieve git config values

#### Resolution (Applied 2025-11-01)
The `.chezmoi.toml.tmpl` template has been updated to handle missing git configuration gracefully:

**Previous Implementation:**
```toml
{{- $email = or (env "EMAIL") (output "git" "config" "user.email" | trim) "codespace@example.com" -}}
```

**Current Implementation:**
```toml
{{- $gitEmail := "" -}}
{{- if lookPath "git" -}}
{{-   $gitEmail = output "git" "config" "--global" "user.email" | trim | default "" -}}
{{- end -}}
{{- $email = env "EMAIL" | default $gitEmail | default "devcontainer@localhost" -}}
```

**Key Improvements:**
- Verifies git command availability using `lookPath "git"`
- Returns empty string on error using `default ""`
- Implements fallback chain for safe default value assignment

---

### Issue 2: `Extension 'twpayne.vscode-chezmoi' not found`

#### Symptoms
```
[04:59:04] Extension 'twpayne.vscode-chezmoi' not found.
Make sure you use the full extension ID, including the publisher, e.g.: ms-dotnettools.csharp
```

#### Root Cause
- Extension ID is incorrect or the extension does not exist
- Extension is not available in the VS Code Marketplace

#### Resolution (Applied 2025-11-01)
The extension reference has been removed from `devcontainer.json`. The chezmoi VS Code extension is not required, as the CLI provides complete functionality.

---

### Issue 3: `ENOTEMPTY: directory not empty, rename`

#### Symptoms
```
[04:59:24] Error while installing the extension github.copilot-chat ENOTEMPTY: directory not empty, rename '/home/vscode/.vscode-server/extensions/.xxx' -> '/home/vscode/.vscode-server/extensions/github.copilot-chat-0.32.4'
```

#### Root Cause
- Race condition during VS Code Server extension installation
- Multiple extensions attempting concurrent installation to the same directory

#### Impact
This is a minor issue. While extension installation fails, the container remains functional. The issue typically resolves automatically upon next container restart.

#### Manual Resolution

Option 1: Clean temporary files
```bash
# Execute within the container
rm -rf /home/vscode/.vscode-server/extensions/.tmp*
# Reload VS Code window
```

Option 2: Rebuild container
```bash
# Open command palette (F1)
# Execute: "Dev Containers: Rebuild Container Without Cache"
```

---

## Preventive Measures

### Configure Git Settings in Advance

**Local Environment:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Automated DevContainer Configuration:**

Add the following to `.devcontainer/devcontainer.json`:
```json
"postCreateCommand": "git config --global user.name 'DevContainer User' && git config --global user.email 'dev@localhost' && bash ${containerWorkspaceFolder}/.devcontainer/scripts/setup-dotfiles.sh"
```

### Use Environment Variables for Explicit Configuration

Configure environment variables in `.devcontainer/devcontainer.json`:
```json
"containerEnv": {
  "EMAIL": "your.email@example.com",
  "GITHUB_USER": "your-username"
}
```

---

## Testing Procedures

### Clean Environment Testing

Execute the following commands to test from a clean state:

```bash
# Remove all chezmoi containers
docker ps -a | grep chezmoi | awk '{print $1}' | xargs docker rm -f

# Remove all devcontainer images (optional)
docker images | grep devcontainers | awk '{print $3}' | xargs docker rmi -f

# Reopen in VS Code
code ~/.local/share/chezmoi
# F1 → "Dev Containers: Rebuild Container Without Cache"
```

### Expected Behavior

1. Container build process (3-5 minutes)
2. postCreateCommand execution
   ```
   [INFO] Installing chezmoi...
   [INFO] ✅ chezmoi installed to /home/vscode/.local/bin
   [INFO] Initializing dotfiles from https://github.com/lv416e/dotfiles.git...
   [INFO] ✅ Dotfiles initialized and applied successfully
   ```
3. Extension installation (concurrent, partial failures acceptable)
4. Container initialization complete

### Verification Commands

Execute within the container:

```bash
# Verify shell configuration
echo $SHELL
# Expected output: /usr/bin/zsh

# Verify chezmoi installation
chezmoi --version
# Expected output: chezmoi version 2.66.1 or higher

# Verify managed files count
chezmoi managed | wc -l
# Expected output: 50 or more

# Verify container detection
chezmoi execute-template "{{ .is_container }}"
# Expected output: true

# Verify email configuration
chezmoi execute-template "{{ .email }}"
# Expected output: devcontainer@localhost or configured email

# Verify git configuration
git config --global user.email
# Expected output: configured email address (or no error)
```

---

## Log Analysis

### Log File Locations

**VS Code Output Panel:**
Navigate to View → Output → Select "Dev Containers" from dropdown

**Critical Log Indicators:**

```
[INFO] Installing chezmoi...
→ chezmoi installation initiated

info installed /home/vscode/.local/bin/chezmoi
→ Installation successful

[INFO] Initializing dotfiles from https://github.com/lv416e/dotfiles.git...
→ Dotfiles initialization started

Cloning into '/home/vscode/.local/share/chezmoi'...
→ Repository cloning in progress

[INFO] ✅ Dotfiles initialized and applied successfully
→ Configuration applied successfully

chezmoi: template: chezmoi.toml:XX:XX: executing...
→ Template error detected (requires resolution)

[ERROR] Failed to initialize dotfiles
→ Critical error encountered
```

### Successful Execution Log Example

```
[INFO] ===================================================================
[INFO] DevContainer Dotfiles Setup
[INFO] ===================================================================
[INFO] Repository: https://github.com/lv416e/dotfiles.git
[INFO]
[INFO] Installing chezmoi...
info found chezmoi version 2.66.1 for latest/linux/arm64
info installed /home/vscode/.local/bin/chezmoi
[INFO] ✅ chezmoi installed to /home/vscode/.local/bin
[INFO] Initializing dotfiles from https://github.com/lv416e/dotfiles.git...
Cloning into '/home/vscode/.local/share/chezmoi'...
remote: Enumerating objects: 2123, done.
[INFO] ✅ Dotfiles initialized and applied successfully
[INFO]
[INFO] ===================================================================
[INFO] Verification
[INFO] ===================================================================
[INFO] Managed files: 87
[INFO] Current SHELL: /usr/bin/zsh
[INFO] Default shell: /usr/bin/zsh
[INFO] zsh: zsh 5.9 (aarch64-ubuntu-linux-gnu)
[INFO]
[INFO] ===================================================================
[INFO] ✅ Setup Complete!
[INFO] ===================================================================
```

---

## Debugging Techniques

### Manual Script Execution

Execute within the container:

```bash
# Run setup script directly
bash /workspaces/chezmoi/.devcontainer/scripts/setup-dotfiles.sh

# Execute chezmoi with verbose output
chezmoi init --apply --verbose https://github.com/lv416e/dotfiles.git
```

### Template Validation

```bash
# Test template execution
chezmoi execute-template < /workspaces/chezmoi/.chezmoi.toml.tmpl

# Verify specific variables
chezmoi execute-template "{{ .is_container }}"
chezmoi execute-template "{{ .email }}"
chezmoi execute-template "{{ .name }}"
```

### Git Configuration Inspection

```bash
# List all global git settings
git config --global --list

# Verify user configuration
git config --global user.name
git config --global user.email

# Inspect git configuration file
cat ~/.gitconfig
```

---

## Emergency Recovery

### Complete Environment Reset

```bash
# Stop and remove all chezmoi containers
docker stop $(docker ps -a -q --filter ancestor=vsc-chezmoi-*)
docker rm $(docker ps -a -q --filter ancestor=vsc-chezmoi-*)

# Remove container images
docker rmi $(docker images -q vsc-chezmoi-*)

# Remove chezmoi configuration (optional)
# Execute within container
rm -rf ~/.local/share/chezmoi
rm -rf ~/.config/chezmoi

# Clear VS Code cache
# F1 → "Dev Containers: Clean Up Dev Containers..."
```

### Minimal Configuration Testing

Create a minimal `devcontainer.json` for isolated testing:

```json
{
  "name": "Minimal Test",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true
    }
  },
  "postCreateCommand": "echo 'Test successful'"
}
```

After successful initialization, incrementally add features to identify the source of any issues.

---

## Support Resources

### Unresolved Issues

If issues persist after following this guide:

**1. Create a GitHub Issue**
- Repository: https://github.com/lv416e/dotfiles/issues
- Template: Bug Report

**2. Required Information:**
```bash
# System information
docker version
code --version

# Complete error log from VS Code Output panel
# Copy the entire output
```

**3. Pre-submission Checklist:**
- [ ] Using latest version of `.chezmoi.toml.tmpl`
- [ ] Using latest version of `.devcontainer/` configuration
- [ ] Docker Desktop updated to current version
- [ ] VS Code updated to current version
- [ ] Dev Containers extension updated to current version

---

## Related Documentation

- [Codespaces and DevContainer Setup Guide](./devcontainer-setup-complete.md)
- [Quick Start Guide](./codespaces-quickstart.md)
- [DevContainer README](../../.devcontainer/README.md)

---

**Last Updated: 2025-11-01**
