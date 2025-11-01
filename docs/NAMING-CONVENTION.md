# Documentation Naming Convention

## Standard Format

All documentation files follow a consistent `kebab-case` naming pattern:

```
{category}-{topic}-{specificity}.md
```

### Rules

1. **All lowercase** - No capitals except in acronyms (e.g., `README.md`)
2. **Hyphen-separated** - Use `-` not `_` or spaces
3. **Noun-based** - Avoid verbs in filenames (e.g., `setup` not `setting-up`)
4. **Specific to general** - Most specific term first
5. **Date suffix** - Version years at end when applicable (e.g., `-2025`)

### Categories

- `adr/` - Architecture Decision Records (numbered: `0001-topic.md`)
- `getting-started/` - Initial setup and onboarding
- `guides/` - Step-by-step tutorials and how-tos
- `reference/` - Technical specifications and reference material
- `explanation/` - Conceptual documentation and design rationale
- `examples/` - Sample configurations and use cases

## File Naming Patterns

### ADRs (Architecture Decision Records)
- Format: `{number}-{decision-topic}.md`
- Example: `0001-adopt-jujutsu-alongside-git.md`
- Pattern: Sequential numbering, topic describes the decision

### Getting Started
- Format: `{task}-{platform}.md`
- Example: `machine-setup-macos.md`
- Pattern: Onboarding tasks for new users or machines

### Guides
- Format: `{tool}-{feature}-{action}.md` or `{platform}-{purpose}.md`
- Examples:
  - `zsh-configuration-switching.md`
  - `codespaces-quickstart.md`
  - `devcontainer-setup.md`
- Pattern: Task-oriented, actionable documentation

### Reference
- Format: `{tool}-{aspect}.md`
- Examples:
  - `mise-tasks.md`
  - `keybindings-tmux.md`
- Pattern: Lookup documentation, factual reference

### Explanation
- Format: `{concept}-{context}.md`
- Examples:
  - `multiplexer-abstraction-design.md`
  - `pre-commit-hooks-rationale.md`
- Pattern: Why and how things work conceptually

## Anti-Patterns to Avoid

❌ **AVOID**:
- Mixed case: `IMPLEMENTATION-GUIDE-2025.md`
- Redundant words: `new-machine-setup.md` (remove "new")
- Vague names: `claude-skills.md` (what about Claude?)
- Tool-specific prefixes when category suffices: `zsh-rollback.md` in guides/ (obvious it's a guide)

✅ **PREFER**:
- `implementation-guide-2025.md`
- `machine-setup.md`
- `claude-code-skills-integration.md`
- `configuration-rollback.md`

## Renaming Checklist

When renaming files:
1. Create new file with correct name
2. Copy content (with improvements)
3. Update all internal references
4. Update any external references (README, etc.)
5. Delete old file
6. Test all links

## Examples of Correct Naming

```
docs/
├── adr/
│   ├── 0001-adopt-jujutsu-alongside-git.md
│   └── 0009-macos-defaults-automation.md
├── getting-started/
│   └── machine-setup-macos.md
├── guides/
│   ├── codespaces-quickstart.md
│   ├── devcontainer-setup.md
│   ├── secrets-management-1password.md
│   └── zsh-configuration-switching.md
├── reference/
│   ├── keybindings-reference.md
│   └── mise-tasks-reference.md
└── explanation/
    ├── multiplexer-abstraction-design.md
    └── pre-commit-hooks-rationale.md
```
