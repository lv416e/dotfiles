# Claude Skills Guide

## Overview

Claude Skills extend Claude Code with specialized knowledge and workflows. They are **model-invoked** capabilities that Claude autonomously activates based on task context.

This guide covers:
- What Skills are and how they work
- How we manage them with chezmoi
- Available Skills in our collection
- How to add/remove Skills
- Best practices

## What are Claude Skills?

### Key Concepts

**Model-Invoked vs User-Invoked**
- **Skills (Model-Invoked)**: Claude automatically decides when to use them based on context
- **Slash Commands (User-Invoked)**: You explicitly call them with `/command`

**Token Efficiency**
- Initial load: **30-50 tokens** (name + description only)
- Full load: Complete content loaded only when relevant
- Compare to MCP servers: can consume tens of thousands of tokens constantly

**Universal Compatibility**
- Works across Claude.ai, Claude Code (CLI), and Claude API
- Build once, use everywhere

### How Skills Work

1. **Discovery**: Claude scans three locations for Skills:
   - Personal: `~/.claude/skills/` (you)
   - Project: `.claude/skills/` (team, via git)
   - Plugins: Bundled with installed plugins

2. **Activation**: Claude reads name + description (30-50 tokens each)

3. **Matching**: Based on your request, Claude decides if a Skill is relevant

4. **Loading**: If relevant, loads full Skill content and follows instructions

5. **Execution**: Uses tools and workflows defined in the Skill

### Skill Structure

Each Skill is a directory with `SKILL.md`:

```markdown
---
name: skill-name
description: What it does and when to use it
---

# Skill Name

## Instructions

[Detailed instructions for Claude]

## Examples

[Usage examples]
```

Optional supporting files:
```
skill-name/
├── SKILL.md          # Required
├── scripts/          # Optional: helper scripts
├── templates/        # Optional: template files
└── docs/            # Optional: documentation
```

## Installed Skills

We have **13 Skills** from two trusted sources:

### From anthropics/skills (Official)

1. **skill-creator** - Guidelines for creating effective Skills
2. **artifacts-builder** - Build HTML artifacts with React + Tailwind
3. **mcp-builder** - Create Model Context Protocol servers
4. **template-skill** - Starter template for new Skills

### From obra/superpowers (Community)

**Development Workflows:**
- **test-driven-development** - TDD with RED-GREEN-REFACTOR
- **systematic-debugging** - 4-phase root cause analysis
- **defense-in-depth** - Multi-layer validation before completion

**Planning & Collaboration:**
- **brainstorming** - Structured ideation sessions
- **writing-plans** - Create actionable plans with checkpoints
- **executing-plans** - Systematic plan execution with tracking

**Code Review & Git:**
- **requesting-code-review** - Prepare code reviews with context
- **using-git-worktrees** - Parallel development with git worktree

**Meta Skills:**
- **writing-skills** - Superpowers-specific guide for creating Skills

See [`~/.claude/skills/README.md`](../../.claude/skills/README.md) for detailed descriptions.

## Management with chezmoi

### Why chezmoi?

- **Version Control**: Track Skills changes in git
- **Cross-Machine Sync**: Same Skills on all your machines
- **Team Sharing**: Share via dotfiles repository
- **Rollback**: Easy to revert changes

### Architecture

```
~/.local/share/chezmoi/
└── dot_claude/
    └── skills/
        ├── README.md
        ├── skill-creator/
        │   ├── SKILL.md
        │   └── scripts/
        ├── brainstorming/
        │   └── SKILL.md
        └── ...

↓ chezmoi apply ↓

~/.claude/
└── skills/
    ├── README.md
    ├── skill-creator/
    │   ├── SKILL.md
    │   └── scripts/
    ├── brainstorming/
    │   └── SKILL.md
    └── ...
```

### Adding New Skills

**Method 1: From a Repository**

```bash
# Clone the repository
cd /tmp
git clone https://github.com/username/skill-repo

# Copy desired skill
cp -r skill-repo/my-skill ~/.claude/skills/

# Add to chezmoi
chezmoi add ~/.claude/skills/my-skill

# Verify
chezmoi diff

# Apply (if needed)
chezmoi apply

# Commit
cd ~/.local/share/chezmoi
git add dot_claude/skills/my-skill
git commit -m "feat: add my-skill Claude Skill"
git push
```

**Method 2: Create Your Own**

```bash
# Create from template
mkdir -p ~/.claude/skills/my-custom-skill

cat > ~/.claude/skills/my-custom-skill/SKILL.md << 'EOF'
---
name: my-custom-skill
description: Brief description of what this skill does and when to use it
---

# My Custom Skill

## Instructions

[Your instructions here]

## Examples

[Your examples here]
EOF

# Add to chezmoi
chezmoi add ~/.claude/skills/my-custom-skill
chezmoi apply

# Commit
cd ~/.local/share/chezmoi
git add dot_claude/skills/my-custom-skill
git commit -m "feat: add custom skill for [purpose]"
git push
```

**Method 3: Via Claude Code Marketplace**

```bash
# Add marketplace
/plugin marketplace add anthropics/skills

# Browse available skills
# (Claude Code will show you options)

# Install a skill
/plugin install document-skills

# The plugin bundles Skills automatically
# No need to manually add to chezmoi in this case
```

### Removing Skills

```bash
# Remove from filesystem
rm -rf ~/.claude/skills/unwanted-skill

# Update chezmoi
chezmoi add ~/.claude/skills

# Or use re-add to sync
chezmoi re-add

# Commit deletion
cd ~/.local/share/chezmoi
git add -A
git commit -m "remove: unwanted-skill Claude Skill"
git push
```

### Updating Skills

```bash
# Update the Skill files directly
nano ~/.claude/skills/my-skill/SKILL.md

# Re-add to chezmoi
chezmoi add ~/.claude/skills/my-skill

# Commit
cd ~/.local/share/chezmoi
git add dot_claude/skills/my-skill
git commit -m "update: improve my-skill description"
git push
```

## Using Skills

### Discovery

Ask Claude what Skills are available:

```
What Skills are available?
```

Claude will list all Skills from all three sources (personal, project, plugins).

### Triggering Skills

Skills activate automatically based on natural language. Use language that matches the Skill's description:

**Examples:**

| To Activate | Say |
|-------------|-----|
| `brainstorming` | "Let's brainstorm ideas for..." |
| `systematic-debugging` | "I need to debug this issue" |
| `writing-plans` | "Create a plan for implementing X" |
| `test-driven-development` | "Let's write this feature using TDD" |
| `requesting-code-review` | "Prepare this for code review" |

### Verification

Skills are working if Claude:
1. Follows specialized workflows (e.g., RED-GREEN-REFACTOR for TDD)
2. Uses domain-specific terminology
3. Applies structured approaches automatically

## Restoring on New Machines

When setting up a new machine with your dotfiles:

```bash
# Clone dotfiles
chezmoi init https://github.com/yourusername/dotfiles

# Apply (includes Skills)
chezmoi apply

# Verify
ls -la ~/.claude/skills/
```

All 13 Skills will be automatically deployed!

## Best Practices

### Creating Skills

1. **Single Purpose**: One Skill = one clear capability
2. **Specific Description**: Include both what it does and when to use it
3. **Examples**: Show expected behavior
4. **Dependencies**: Document required tools/libraries
5. **Testing**: Test with actual tasks before deploying

### Managing Skills

1. **Version Control**: Always commit Skills via chezmoi
2. **Documentation**: Update README.md when adding new Skills
3. **Review**: Test Skills work as expected after updates
4. **Cleanup**: Remove unused Skills to reduce token overhead

### Security

1. **Trust Sources**: Only install from:
   - `anthropics/skills` (official)
   - `obra/superpowers` (well-known community)
   - Your own organization's repositories

2. **Review Code**: Always review `SKILL.md` and scripts before adding

3. **Limit Tools**: Use `allowed-tools` field for read-only Skills:
   ```yaml
   ---
   name: read-only-analyzer
   description: Analyzes code without changes
   allowed-tools:
     - Read
     - Grep
     - Glob
   ---
   ```

## Troubleshooting

### Skill Not Discovered

**Problem**: Claude doesn't see the Skill

**Solutions**:
- Check file path: `~/.claude/skills/SKILL-NAME/SKILL.md`
- Verify YAML frontmatter syntax
- Ensure `name` and `description` fields exist
- Ask: "What Skills are available?" to confirm

### Skill Not Activating

**Problem**: Skill exists but doesn't trigger

**Solutions**:
- Make description more specific
- Include trigger phrases in description
- Use language that matches the description
- Check if similar Skills might be competing

### Skills Not Syncing

**Problem**: chezmoi not updating Skills

**Solutions**:
```bash
# Force re-add
chezmoi re-add

# Force apply
chezmoi apply --force ~/.claude/skills

# Check for changes
chezmoi diff

# Verify source exists
ls ~/.local/share/chezmoi/dot_claude/skills/
```

## Advanced Topics

### Project-Specific Skills

For team-shared Skills, use project directory:

```bash
cd ~/my-project

# Create project Skill
mkdir -p .claude/skills/project-specific
cat > .claude/skills/project-specific/SKILL.md << 'EOF'
---
name: project-test-runner
description: Run this project's specific test suite
---
# Project Test Runner
...
EOF

# Commit to project repo (not dotfiles)
git add .claude/skills/
git commit -m "Add project-specific test runner skill"
git push
```

Team members get it automatically on `git pull`.

### Skills with Scripts

Skills can include executable scripts:

```bash
skill-name/
├── SKILL.md
└── scripts/
    ├── init.sh
    ├── validate.py
    └── helper.js
```

Reference in SKILL.md:
```markdown
## Setup

Run initialization:
\`\`\`bash
~/.claude/skills/skill-name/scripts/init.sh
\`\`\`
```

### Encrypted Skills (Sensitive)

For Skills with API keys or secrets:

```bash
# Encrypt with age
chezmoi add --encrypt ~/.claude/skills/secret-skill

# Appears as:
# encrypted_dot_claude/skills/encrypted_secret-skill/
#   └── encrypted_SKILL.md.age
```

See [chezmoi encryption guide](./chezmoi-encryption.md) for setup.

## Resources

### Official Documentation
- Skills announcement: https://www.anthropic.com/news/skills
- Engineering deep-dive: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- Help Center: https://support.claude.com/en/articles/12512198-how-to-create-custom-skills

### Community Resources
- Simon Willison's analysis: https://simonwillison.net/2025/Oct/16/claude-skills/
- Awesome Claude Skills: https://github.com/travisvn/awesome-claude-skills

### Source Repositories
- Official Skills: https://github.com/anthropics/skills
- Superpowers: https://github.com/obra/superpowers
- Skills Powerkit: https://github.com/jeremylongshore/claude-code-plugins-plus

## Summary

✅ **13 Skills installed** from trusted sources
✅ **chezmoi managed** for version control and sync
✅ **Automatic activation** based on task context
✅ **Token efficient** (30-50 tokens per Skill initially)
✅ **Cross-machine deployment** via dotfiles
✅ **Team shareable** via git repositories

Skills extend Claude Code's capabilities without MCP overhead. They're simple to create (just Markdown), easy to manage (chezmoi + git), and powerful in practice (specialized workflows).

---

**Next Steps:**
1. Try asking Claude: "What Skills are available?"
2. Test a Skill: "Let's brainstorm ideas for..."
3. Create your own: See [template-skill](../../.claude/skills/template-skill/SKILL.md)

*Last updated: 2025-10-30*
