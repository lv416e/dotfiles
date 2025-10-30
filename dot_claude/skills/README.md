# Claude Skills Collection

This directory contains Claude Skills that extend Claude Code's capabilities with specialized knowledge and workflows.

## What are Skills?

Skills are **model-invoked** capabilities - Claude autonomously decides when to use them based on:
- Your request context
- The skill's description and metadata
- Current task requirements

Unlike slash commands (user-invoked), Skills activate automatically when relevant.

## Installed Skills

### Development Workflows

#### Test-Driven Development
**Skill**: `test-driven-development`
**Source**: obra/superpowers
**Purpose**: Follow RED-GREEN-REFACTOR TDD patterns with proper test-first development workflow.

#### Systematic Debugging
**Skill**: `systematic-debugging`
**Source**: obra/superpowers
**Purpose**: Use 4-phase root cause analysis for debugging: reproduce, isolate, fix, verify.

#### Defense in Depth
**Skill**: `defense-in-depth`
**Source**: obra/superpowers
**Purpose**: Verification before completion with multi-layer validation checks.

### Planning & Collaboration

#### Brainstorming
**Skill**: `brainstorming`
**Source**: obra/superpowers
**Purpose**: Structured brainstorming and design refinement sessions.

#### Writing Plans
**Skill**: `writing-plans`
**Source**: obra/superpowers
**Purpose**: Create detailed, actionable plans with checkpoints and milestones.

#### Executing Plans
**Skill**: `executing-plans`
**Source**: obra/superpowers
**Purpose**: Execute plans systematically with progress tracking and validation.

### Code Review & Git

#### Requesting Code Review
**Skill**: `requesting-code-review`
**Source**: obra/superpowers
**Purpose**: Prepare and request code reviews with proper context and documentation.

#### Using Git Worktrees
**Skill**: `using-git-worktrees`
**Source**: obra/superpowers
**Purpose**: Manage parallel development branches using git worktree workflows.

### Building & Creation

#### Artifacts Builder
**Skill**: `artifacts-builder`
**Source**: anthropics/skills
**Purpose**: Build complex HTML artifacts using React and Tailwind CSS.

#### MCP Builder
**Skill**: `mcp-builder`
**Source**: anthropics/skills
**Purpose**: Guidance for creating Model Context Protocol (MCP) servers.

### Meta Skills (Creating Skills)

#### Skill Creator
**Skill**: `skill-creator`
**Source**: anthropics/skills
**Purpose**: Guidelines and best practices for developing effective Claude Skills.

#### Writing Skills
**Skill**: `writing-skills`
**Source**: obra/superpowers
**Purpose**: Superpowers-specific guide for creating and sharing skills.

#### Template Skill
**Skill**: `template-skill`
**Source**: anthropics/skills
**Purpose**: Starter template for creating new skills with proper structure.

## How to Use

Skills activate automatically based on context. To see available skills:

```
What Skills are available?
```

To trigger a specific skill, use language that matches its description. For example:
- "Let's brainstorm ideas for..." → activates `brainstorming`
- "I need to debug this issue" → activates `systematic-debugging`
- "Create a plan for..." → activates `writing-plans`

## Directory Structure

Each skill is a self-contained directory with:
```
skill-name/
├── SKILL.md          # Main skill definition (YAML frontmatter + instructions)
├── scripts/          # Optional: helper scripts
├── templates/        # Optional: template files
└── docs/            # Optional: additional documentation
```

## Management with chezmoi

This skills directory is managed via chezmoi for version control and cross-machine synchronization.

**Add new skills**:
```bash
# Copy skill to ~/.claude/skills/
cp -r /path/to/new-skill ~/.claude/skills/

# Update chezmoi
chezmoi add ~/.claude/skills/new-skill
chezmoi apply
```

**Remove skills**:
```bash
rm -rf ~/.claude/skills/unwanted-skill
chezmoi add ~/.claude/skills  # Update chezmoi state
```

## Sources

- **anthropics/skills**: https://github.com/anthropics/skills (Official Anthropic repository)
- **obra/superpowers**: https://github.com/obra/superpowers (Community core skills library)

## Token Efficiency

Skills are lightweight:
- **Initial load**: 30-50 tokens (name + description only)
- **Full load**: Complete content loaded only when relevant to task

This makes skills extremely efficient compared to always-loaded context (e.g., MCP servers can consume tens of thousands of tokens).

## Best Practices

1. **Keep skills focused**: One skill = one clear purpose
2. **Write specific descriptions**: Include both functionality and usage triggers
3. **Test before deploying**: Verify skills work as expected
4. **Document dependencies**: Note any required tools or libraries
5. **Version control**: Track changes in git via chezmoi

## Availability

Skills are available on:
- Claude Code (CLI) ✓
- Claude.ai (Pro/Max/Team/Enterprise plans)
- Claude API

## Learn More

- Official Skills announcement: https://www.anthropic.com/news/skills
- Engineering deep-dive: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- Simon Willison's analysis: https://simonwillison.net/2025/Oct/16/claude-skills/

---

*Last updated: 2025-10-30*
*Managed with chezmoi: https://www.chezmoi.io*
