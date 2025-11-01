# GitHub Codespaces and DevContainer Quick Start

## Setup Overview

This guide provides instructions for configuring your development environment using GitHub Codespaces or local DevContainers. Complete setup takes approximately 2-5 minutes.

### GitHub Codespaces Configuration

**1. Configure dotfiles in GitHub Settings**

Navigate to your Codespaces settings: https://github.com/settings/codespaces

- Enable "Automatically install dotfiles"
- Select repository: `lv416e/dotfiles`
- Save the configuration

**2. Create a Codespace**

From any repository:
1. Select the **Code** dropdown
2. Navigate to the **Codespaces** tab
3. Select **Create codespace on [branch]**

**3. Verification**

Your zsh environment will be automatically configured with all managed dotfiles upon Codespace initialization.

---

### Local DevContainer Configuration

**1. Install Required Extension**

Install the Dev Containers extension for Visual Studio Code:
- Extension ID: `ms-vscode-remote.remote-containers`
- Available from the VS Code Marketplace

**2. Initialize Container Environment**

1. Open the command palette (F1 or Cmd/Ctrl+Shift+P)
2. Execute: "Dev Containers: Reopen in Container"

**3. Build Process**

The initial container build requires approximately 3-5 minutes. Subsequent builds utilize cached layers for faster startup.

---

## Environment Verification

Execute the following commands to verify successful configuration:

```bash
# Verify shell configuration
echo $SHELL
# Expected output: /usr/bin/zsh

# List managed dotfiles
chezmoi managed | head

# Verify environment detection
chezmoi execute-template "{{ .is_codespaces }}"
```

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| Terminal defaults to bash | Reload the VS Code window: F1 → "Developer: Reload Window" |
| Development tools unavailable | Rebuild the container: F1 → "Dev Containers: Rebuild Container" |
| Dotfiles not applied | Verify the install script has execute permissions: `chmod +x install` |

---

## Additional Documentation

For comprehensive setup instructions, refer to the [DevContainer Setup Guide](./devcontainer-setup-complete.md).

---

## Included Features

This configuration provides the following capabilities:

- **Shell Environment**: zsh with Powerlevel10k prompt theme
- **Dotfile Management**: Complete synchronization from your chezmoi repository
- **Automated Setup**: Non-interactive installation suitable for cloud environments
- **Optimized Performance**: 3-5 minute initialization (compared to 15-20 minutes without optimization)
- **Environment Consistency**: Identical configuration across local and cloud development environments

---

## Secrets Management in Codespaces

For GitHub Codespaces environments, use GitHub Secrets instead of 1Password CLI:

1. Navigate to your Codespaces secrets settings: https://github.com/settings/codespaces
2. Select the **Secrets** tab
3. Add required secrets (e.g., `GITHUB_TOKEN`, `NPM_TOKEN`)
4. Secrets are automatically injected into all Codespaces environments

Template files automatically fall back to `{{ env "GITHUB_TOKEN" }}` when 1Password is unavailable.

---

## Configuration Recommendations

### Terminal Behavior
The initial terminal in Codespaces web interface defaults to bash. To access your configured zsh environment, open a new terminal instance.

### Font Configuration
Install a Nerd Font on your local machine to properly render Powerlevel10k glyphs and icons.

### Performance Optimization
Packages are installed using DevContainer Features, which provide built-in caching for improved build times.

### Homebrew Handling
Brewfile execution is automatically skipped in container environments, reducing initialization time by approximately 10 minutes.

---

## Updating Dotfiles

To synchronize your environment with the latest dotfile changes:

```bash
chezmoi update
```

Updates are applied immediately without requiring container restart.

---

## Additional Resources

- [Complete Setup Guide](./devcontainer-setup-complete.md)
- [chezmoi Documentation](https://www.chezmoi.io/)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [Development Containers Specification](https://containers.dev/)
