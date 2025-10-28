# DevContainer Integration with Chezmoi Dotfiles

This directory contains example configurations for integrating your chezmoi-managed dotfiles with VS Code DevContainers and GitHub Codespaces.

## Overview

DevContainers provide isolated, reproducible development environments. When combined with chezmoi dotfiles, you get:

- **Consistent Environment**: Your personal shell configuration, aliases, and tools in every container
- **Automatic Setup**: Dotfiles applied automatically on container creation
- **Zero Manual Configuration**: No need to manually install or configure tools

## Files

- `devcontainer.json` - Example DevContainer configuration with dotfiles integration
- `README.md` - This file

## Quick Start

### 1. Configure VS Code Dotfiles Settings

Add to your VS Code `settings.json`:

```json
{
  "dotfiles.repository": "YOUR_USERNAME/dotfiles",
  "dotfiles.targetPath": "~/dotfiles",
  "dotfiles.installCommand": "~/dotfiles/install.sh"
}
```

This is automatically configured if you're using the chezmoi-managed VSCode settings from `~/.config/Code/User/settings.json`.

### 2. Add DevContainer to Your Project

Copy `devcontainer.json` to your project:

```bash
mkdir -p .devcontainer
cp docs/examples/devcontainer/devcontainer.json .devcontainer/
```

Edit the file to customize:
- Base image (`"image"`)
- Features (language runtimes, tools)
- VS Code extensions
- Your GitHub username in `"dotfiles.repository"`

### 3. Open in DevContainer

**VS Code:**
1. Open Command Palette (Cmd+Shift+P)
2. Select "Dev Containers: Reopen in Container"
3. Wait for container build and dotfiles application

**GitHub Codespaces:**
1. Create a new Codespace from your repository
2. Dotfiles are automatically applied on creation

## How It Works

### Automatic Dotfiles Application

When a DevContainer or Codespace starts:

1. **Clone**: VS Code clones your dotfiles repository to `~/dotfiles`
2. **Install**: Runs `~/dotfiles/install.sh` (our non-interactive installer)
3. **Apply**: Chezmoi applies all your configurations
4. **Tools**: Mise installs development tools (Node, Python, Rust, etc.)

### Environment Detection

The `install.sh` script automatically detects the environment:

```bash
# Environment variables set by VS Code/GitHub
CODESPACES=true         # GitHub Codespaces
REMOTE_CONTAINERS=true  # VS Code DevContainer
```

This enables container-specific optimizations:
- Disable Homebrew auto-update (faster startup)
- Skip interactive prompts
- Create marker file at `~/.config/container-type`

## Customization

### Per-Project DevContainer

Different projects may need different environments:

```json
{
  "name": "Python ML Project",
  "image": "mcr.microsoft.com/devcontainers/python:3.13",
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.13"
    }
  }
}
```

### Conditional Configuration in Dotfiles

Use chezmoi templates to conditionally configure based on environment:

```zsh
# In your zsh config
{{- if (env "CODESPACES") }}
# Codespaces-specific config
export PS1="[CODESPACE] $PS1"
{{- else if (env "REMOTE_CONTAINERS") }}
# DevContainer-specific config
export PS1="[CONTAINER] $PS1"
{{- end }}
```

Or check the marker file:

```zsh
if [ -f ~/.config/container-type ]; then
  CONTAINER_TYPE=$(cat ~/.config/container-type)
  echo "Running in: $CONTAINER_TYPE"
fi
```

## Troubleshooting

### Dotfiles Not Applied

1. Check VS Code settings: `"dotfiles.repository"` is set correctly
2. Verify `install.sh` is executable: `chmod +x install.sh`
3. Check container logs: View → Output → "Dev Containers"

### Permission Errors

If you encounter permission errors:

```json
{
  "remoteUser": "vscode",
  "containerEnv": {
    "USER": "vscode"
  }
}
```

### Slow Container Startup

Optimize by:
- Using a smaller base image
- Reducing number of features
- Caching mise-installed tools in Docker layer

## Best Practices

1. **Keep install.sh Non-Interactive**: Never use prompts or interactive commands
2. **Idempotent Installation**: Script should be safe to run multiple times
3. **Fast Startup**: Defer non-essential tool installation
4. **Version Consistency**: Use mise to ensure same tool versions across all environments
5. **Documentation**: Keep `devcontainer.json` well-commented

## References

- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [GitHub Codespaces](https://docs.github.com/en/codespaces)
- [Chezmoi Containers Guide](https://www.chezmoi.io/user-guide/machines/containers-and-vms/)
- [Dev Container Features](https://containers.dev/features)
- [Dev Container Specification](https://containers.dev/)

## Testing

Test your dotfiles in a container:

```bash
# Using Docker directly
docker run -it --rm mcr.microsoft.com/devcontainers/base:ubuntu bash
git clone https://github.com/YOUR_USERNAME/dotfiles ~/dotfiles
~/dotfiles/install.sh

# Or use VS Code
# 1. Open this repo in VS Code
# 2. Dev Containers: Reopen in Container
# 3. Check that dotfiles are applied
```

## Examples

### Python Data Science Container

```json
{
  "name": "Python Data Science",
  "image": "mcr.microsoft.com/devcontainers/python:3.13",
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.13"
    }
  },
  "postCreateCommand": "pip install numpy pandas matplotlib jupyter"
}
```

### Full-Stack TypeScript Container

```json
{
  "name": "TypeScript Full-Stack",
  "image": "mcr.microsoft.com/devcontainers/typescript-node:20",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    }
  }
}
```

### Go Microservices Container

```json
{
  "name": "Go Microservices",
  "image": "mcr.microsoft.com/devcontainers/go:1",
  "features": {
    "ghcr.io/devcontainers/features/go:1": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  }
}
```
