# File Renaming Map

## Files to Rename

### guides/

| Current Name | New Name | Reason |
|--------------|----------|--------|
| `IMPLEMENTATION-GUIDE-2025.md` | `tooling-implementation-guide-2025.md` | Mixed case → kebab-case, more descriptive |
| `claude-skills.md` | `claude-code-skills-integration.md` | Too vague, specify what aspect |
| `codespaces-devcontainer-setup.md` | `devcontainer-setup-complete.md` | Codespaces implied by devcontainer |
| `codespaces-quick-start.md` | `codespaces-quickstart.md` | Standardize compound words |
| `fnox-secrets-management.md` | `secrets-management-fnox.md` | Category-first ordering |
| `macos-defaults-automation.md` | `macos-defaults-automation-guide.md` | Clarify it's a guide |
| `secrets-management.md` | `secrets-management-overview.md` | Distinguish from tool-specific guides |
| `tmux-status-bar.md` | `tmux-statusbar-customization.md` | More specific, compound word |
| `troubleshooting-devcontainer.md` | `devcontainer-troubleshooting.md` | Tool-first consistency |
| `zed-editor-setup.md` | `zed-configuration-guide.md` | "Setup" → "Configuration" (more precise) |
| `zsh-config-switching.md` | `zsh-configuration-switching.md` | Expand abbreviation |
| `zsh-rollback.md` | `zsh-configuration-rollback.md` | More descriptive |

### getting-started/

| Current Name | New Name | Reason |
|--------------|----------|--------|
| `new-machine-setup.md` | `machine-setup-macos.md` | Remove redundant "new", specify platform |

### explanation/

| Current Name | New Name | Reason |
|--------------|----------|--------|
| `multiplexer-abstraction.md` | `multiplexer-abstraction-design.md` | Clarify it explains design |
| `pre-commit-hooks.md` | `pre-commit-hooks-rationale.md` | Clarify it explains rationale |
| `zsh-modular-config.md` | `zsh-modular-configuration-design.md` | More descriptive |

### reference/

| Current Name | New Name | Reason |
|--------------|----------|--------|
| `helix-setup.md` | `helix-configuration-reference.md` | "Setup" → "Configuration reference" |
| `keybindings.md` | `keybindings-reference.md` | Add "reference" suffix |
| `mise-tasks.md` | `mise-tasks-reference.md` | Add "reference" suffix |
| `new-tools.md` | `tools-evaluation-criteria.md` | More descriptive purpose |
| `raycast-extensions.md` | `raycast-extensions-reference.md` | Add "reference" suffix |
| `terminal-multiplexers.md` | `terminal-multiplexers-comparison.md` | Specify it's a comparison |

### adr/

No changes needed - already following numbered ADR convention.

### examples/

No changes needed - single subdirectory with clear README.

## Files Already Correct

These files follow the naming convention:
- All files in `adr/` (numbered ADR format)
- `docs/README.md`
- `adr/README.md`
- `examples/devcontainer/README.md`

## Total Changes

- **25 files** to rename
- **Categories affected**: guides (12), getting-started (1), explanation (3), reference (6)
- **No changes**: adr (9 files + README), examples (1 README)
