# promptq - Prompt Queue Manager for Claude Code

A lightweight, JSONL-based queue system for managing and sending prompts to Claude Code. Perfect for batching questions, organizing thoughts, and maintaining a workflow when working with AI assistants.

## Features

- **JSONL Queue**: Simple, text-based queue format (one JSON object per line)
- **Multiple Send Methods**:
  - tmux send-keys (automatic Claude pane detection)
  - Clipboard copy (pbcopy/xclip)
  - Manual output
- **Tag-Based Organization**: Filter and organize prompts with hashtags
- **Template System**: Pre-made prompt templates with variable substitution
- **Interactive Selection**: Use fzf for visual selection
- **FIFO & Manual Modes**: Send in order or pick specific prompts

## Installation

```bash
# Already installed via chezmoi at:
~/.local/bin/promptq

# Verify installation
promptq version
```

## Quick Start

```bash
# Add a simple prompt
promptq add "Explain async/await in JavaScript"

# Add with tags for organization
promptq add "Review this PR" "#review #urgent"

# List all prompts
promptq list

# Send first prompt (FIFO)
promptq send

# Interactive selection with fzf
promptq select-send

# Filter by tag
promptq filter "#rust"

# Show all tags
promptq tags

# Use snippets (reusable prompts)
promptq snippet list
promptq snippet add daily-standup

# Use templates (with variables)
promptq template add explain-concept CONCEPT="async/await" LANGUAGE="rust"
```

## Usage

### Basic Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `promptq add <text> [#tags]` | `a` | Add prompt to queue |
| `promptq list` | `ls`, `l` | List all queued prompts |
| `promptq count` | `c` | Show queue size |
| `promptq send` | `s` | Send first prompt (FIFO) |
| `promptq select-send` | `ss` | Interactive send with fzf |
| `promptq filter <#tag>` | `f` | Filter prompts by tag |
| `promptq tags` | `t` | List all tags with counts |
| `promptq clear` | `clr` | Clear all queued prompts |
| `promptq help` | `h` | Show help message |
| `promptq version` | `v` | Show version |

### Template Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `promptq template list` | `tmpl ls` | List available templates |
| `promptq template show <name>` | `tmpl s` | Show template content |
| `promptq template add <name> [VARS]` | `tmpl a` | Add prompt from template |

### Snippet Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `promptq snippet list` | `snip ls` | List available snippets |
| `promptq snippet show <name>` | `snip s` | Show snippet content |
| `promptq snippet add <name>` | `snip a` | Add prompt from snippet |

## Templates

### Using Templates

Templates are stored in `~/.config/promptq/templates/` with `.tmpl` extension.

```bash
# List available templates
promptq template list

# View template content
promptq template show explain-concept

# Use template with variable substitution
promptq template add explain-concept \
  CONCEPT="async/await" \
  LANGUAGE="rust"
```

### Built-in Templates

#### code-review.tmpl
Review code changes with focus areas.

**Variables**: `FILE_PATH`, `DESCRIPTION`

**Example**:
```bash
promptq template add code-review \
  FILE_PATH="src/main.rs" \
  DESCRIPTION="Added error handling"
```

#### debug-help.tmpl
Get help debugging an issue.

**Variables**: `FEATURE`, `ERROR_MESSAGE`, `EXPECTED`, `ACTUAL`

**Example**:
```bash
promptq template add debug-help \
  FEATURE="authentication" \
  ERROR_MESSAGE="401 Unauthorized" \
  EXPECTED="User should be logged in" \
  ACTUAL="Getting 401 error"
```

#### explain-concept.tmpl
Request explanation of a programming concept.

**Variables**: `CONCEPT`, `LANGUAGE`

**Example**:
```bash
promptq template add explain-concept \
  CONCEPT="ownership" \
  LANGUAGE="rust"
```

### Creating Custom Templates

Create a new file in `~/.config/promptq/templates/`:

```bash
# Example: custom-template.tmpl
I need help with ${TASK} in ${PROJECT}.

Details:
${DETAILS}

Please provide ${OUTPUT_FORMAT}.

#custom #${PROJECT}
```

Use variables in format: `${VARIABLE_NAME}` (must be uppercase).

Tags can be added on the last line starting with `#`.

## Snippets

Snippets are **reusable, fixed prompts** that can be added to your queue multiple times without modification. Unlike templates, snippets don't use variables - they're ready-to-use prompts you find yourself using repeatedly.

### Using Snippets

Snippets are stored in `~/.config/promptq/snippets/` with `.txt` extension.

```bash
# List available snippets
promptq snippet list

# View snippet content
promptq snippet show daily-standup

# Add snippet to queue (can be used repeatedly)
promptq snippet add daily-standup
```

### Built-in Snippets

#### daily-standup.txt
Quick daily standup format prompt.

**Example**:
```bash
promptq snippet add daily-standup
```

#### code-review-checklist.txt
Comprehensive code review checklist.

**Example**:
```bash
promptq snippet add code-review-checklist
```

#### explain-like-im-five.txt
Request simple, beginner-friendly explanations.

**Example**:
```bash
promptq snippet add explain-like-im-five
```

### Creating Custom Snippets

Create a new file in `~/.config/promptq/snippets/`:

```bash
# Example: refactor-plan.txt
Please help me create a refactoring plan for the following code:

1. Identify code smells and issues
2. Suggest improvements
3. Prioritize changes by impact
4. Consider backwards compatibility

#refactor #planning
```

Snippets can include tags on the last line (just like templates).

### Snippets vs Templates

- **Snippets**: Fixed text, reusable, no variables
  - Example: "Daily standup update format"
  - Use when: Same prompt every time
- **Templates**: Parameterized text with variables
  - Example: "Explain ${CONCEPT} in ${LANGUAGE}"
  - Use when: Same structure, different values

## Tag System

### Adding Tags

Tags are specified with `#` prefix when adding prompts:

```bash
promptq add "Fix memory leak" "#bug #urgent #memory"
```

Tags can also be included in templates:

```tmpl
My prompt text here

#tag1 #tag2 #tag3
```

### Filtering by Tags

```bash
# Show all prompts tagged with #rust
promptq filter "#rust"

# List all tags with usage counts
promptq tags
```

### Tag Naming Conventions

- Use lowercase: `#rust` not `#Rust`
- Use hyphens for multi-word: `#code-review` not `#code_review`
- Be consistent: Choose either `#js` or `#javascript` and stick to it

### Suggested Tags

- **By Language**: `#rust`, `#python`, `#javascript`, `#go`
- **By Task Type**: `#review`, `#debug`, `#refactor`, `#learning`
- **By Priority**: `#urgent`, `#low-priority`
- **By Category**: `#performance`, `#security`, `#testing`, `#documentation`

## File Structure

```
~/.config/promptq/
├── queue.jsonl          # Active queue (JSONL format)
├── sent.jsonl          # Sent prompts log
├── templates/          # Parameterized templates
│   ├── code-review.tmpl
│   ├── debug-help.tmpl
│   └── explain-concept.tmpl
├── snippets/           # Reusable fixed prompts
│   ├── daily-standup.txt
│   ├── code-review-checklist.txt
│   └── explain-like-im-five.txt
├── README.md           # This file
└── INTEGRATION.md      # Editor integration guide
```

### Queue Format

Each line in `queue.jsonl` is a JSON object:

```json
{"ts":"2025-10-27T00:09:35+0900","text":"How do I implement error handling in Rust?","tags":["rust","error-handling"]}
```

- `ts`: ISO 8601 timestamp with timezone
- `text`: The prompt text
- `tags`: Array of tags (without `#` prefix)

## Send Priority

When you run `promptq send`, it tries these methods in order:

1. **tmux send-keys**: Automatically detects Claude Code running in tmux pane
2. **Clipboard copy**: Falls back to `pbcopy` (macOS) or `xclip`/`xsel` (Linux)
3. **Manual output**: Prints prompt to terminal for manual copying

### tmux Integration

`promptq` automatically detects tmux panes with the following priority:
1. **Environment variable**: `export PROMPTQ_PANE="%381"` (highest priority)
2. **Config file**: `~/.config/promptq/config` with `target_pane=%381`
3. **Current window only** (when run inside tmux): Searches current window for "claude" in pane title or command
4. **All windows** (when run outside tmux): Searches all windows for "Claude Code" or "claude"

**Note**: When running `promptq` from inside a tmux session, it **only searches the current window** for Claude panes. This ensures prompts are sent to the nearby Claude instance and prevents accidentally sending to a different window. If no Claude is found in the current window, it will fall back to clipboard copy with a helpful message.

The following tmux workspace scripts automatically set pane titles to "claude" and protect them from being overwritten:
- **tmux-work**: Left-top pane (where you manually start claude)
- **tmux-claude**: Right-top pane (auto-starts claude)
- **tmux-nvim**: Right-top pane (auto-starts claude when `TOP_PANES=2`)

These scripts use `tmux set-option -w automatic-rename off` and `allow-rename off` at the window level to ensure the "claude" title persists even after shells start or commands run.

To manually set a pane title and protect it from being overwritten:
```bash
# First, disable automatic renaming for the window
tmux set-option -w automatic-rename off
tmux set-option -w allow-rename off

# Then set the pane title
tmux select-pane -T "claude"

# Or from another pane/window
tmux set-option -w -t "@77" automatic-rename off
tmux set-option -w -t "@77" allow-rename off
tmux select-pane -t "%381" -T "claude"
```

**Note**: `automatic-rename` and `allow-rename` are **window-level options** (not pane-level), so use `-w` flag and target the window (e.g., `@77`), not the pane.

To configure a specific pane:
```bash
# One-time setup (persists in config file)
promptq config set-pane "%381"

# Verify current target
promptq config show-pane
```

## Workflow Examples

### Code Review Workflow

```bash
# Queue multiple review tasks
promptq add "Review authentication logic" "#review #security"
promptq add "Check error handling" "#review #errors"
promptq add "Verify test coverage" "#review #testing"

# Review queue
promptq list

# Send one at a time as you work through them
promptq send
# ... work with Claude, get response ...
promptq send
# ... continue ...
```

### Learning Session

```bash
# Queue concepts to learn
promptq template add explain-concept CONCEPT="closures" LANGUAGE="javascript"
promptq template add explain-concept CONCEPT="lifetimes" LANGUAGE="rust"
promptq template add explain-concept CONCEPT="generators" LANGUAGE="python"

# Filter learning topics
promptq filter "#learning"

# Interactive selection
promptq select-send
```

### Debug Session

```bash
# Add debug tasks with context
promptq template add debug-help \
  FEATURE="user login" \
  ERROR_MESSAGE="TypeError: Cannot read property 'id' of undefined" \
  EXPECTED="Should get user ID" \
  ACTUAL="Getting undefined"

# Send and work through issues
promptq send
```

### Daily Routine with Snippets

```bash
# Morning standup
promptq snippet add daily-standup
promptq send

# Code review session
promptq snippet add code-review-checklist
promptq send

# Learning something new - combine snippet + specific question
promptq snippet add explain-like-im-five
promptq add "Specifically about Rust's borrow checker" "#rust #learning"
promptq send
promptq send
```

## Integration with Editors

See `INTEGRATION.md` for detailed integration guides for:

- **Neovim**: Lua plugin with visual selection support
- **VS Code**: Tasks and extension implementation
- **Raycast**: Script commands
- **Alfred**: Workflow
- **tmux**: Keybindings and status bar
- **Zsh**: Helper functions

## Tips and Tricks

### 1. Quick Add from Clipboard

```bash
# Add clipboard content with tags
alias pqc='pbpaste | xargs -I {} promptq add "{}" "#clipboard"'
```

### 2. Add Context Automatically

```bash
# Add current git diff to queue
git diff | promptq add "Review these changes" "#git #review"
```

### 3. Batch Processing

```bash
# Add multiple prompts from a file
while IFS= read -r line; do
  promptq add "$line" "#batch"
done < questions.txt
```

### 4. Use with Find/Grep

```bash
# Find TODOs and add to queue
grep -r "TODO" src/ | while read -r line; do
  promptq add "Address: $line" "#todo"
done
```

### 5. Scheduled Sends (with cron)

```bash
# Send one prompt every hour
0 * * * * promptq send
```

## Troubleshooting

### Queue not updating

```bash
# Check queue file permissions
ls -la ~/.config/promptq/queue.jsonl

# Ensure directory exists
mkdir -p ~/.config/promptq
```

### tmux detection not working

```bash
# Manually check tmux panes
tmux list-panes -a -F '#{pane_id} #{pane_current_command} #{pane_title}'

# Set pane title explicitly
printf '\033]2;%s\033\\' 'claudecode'
```

### Template not found

```bash
# List installed templates
ls ~/.config/promptq/templates/

# Check template name (without .tmpl extension)
promptq template list
```

### jq errors

```bash
# Verify jq is installed
which jq

# Check JSONL format validity
jq -c '.' ~/.config/promptq/queue.jsonl
```

## Technical Details

### Dependencies

- **bash** 3.2+ (macOS ships with 3.2.57)
- **jq** - JSON processing
- **fzf** - Interactive selection (optional, for select-send)
- **tmux** - For tmux send-keys integration (optional)
- **pbcopy/xclip/xsel** - Clipboard support (optional)

### Performance

- Queue operations are O(1) for add, O(n) for list/filter
- JSONL format enables streaming processing
- No external databases or services required
- Minimal memory footprint (~2MB for typical queue)

### Security Considerations

- Queue files are stored in `~/.config/promptq/` (user-only access recommended)
- No network access required
- All processing is local
- Sent prompts are logged in `sent.jsonl` for audit trail

## Version History

### v0.1.0 (2025-10-27)
- Initial release
- Basic queue management (add/list/count/send/clear)
- JSONL format with jq integration
- tmux send-keys with auto-detection
- Clipboard fallback
- Interactive selection with fzf
- Tag-based filtering
- Template system with variable substitution
- Built-in templates: code-review, debug-help, explain-concept

## Contributing

This tool is part of a personal dotfiles repository. For bugs or suggestions, create an issue in the main dotfiles repo.

## License

MIT License - Feel free to modify and use as needed.

## Related Tools

- [Claude Code](https://claude.com/claude-code) - The AI assistant this tool is designed for
- [ccusage](https://www.npmjs.com/package/ccusage) - Claude Code usage tracker
- [fzf](https://github.com/junegunn/fzf) - Command-line fuzzy finder
- [jq](https://stedolan.github.io/jq/) - JSON processor
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer

## Acknowledgments

Inspired by:
- Task queue systems (pueue, task-spooler)
- Note-taking workflows (org-mode, Obsidian)
- AI prompt management patterns
