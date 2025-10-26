# promptq Editor Integration Guide

This document describes how to integrate `promptq` with various editors and tools.

## Architecture Overview

`promptq` is designed to be editor-agnostic. All functionality is exposed through a CLI interface that can be called from any editor or automation tool.

### Core Integration Pattern

1. **Capture selection/context** in the editor
2. **Call `promptq add`** with the captured text
3. **Send prompt** using `promptq send` or `promptq select-send`

## Neovim Integration

### Basic Integration (Lua)

Create `~/.config/nvim/lua/promptq.lua`:

```lua
local M = {}

-- Add visual selection to promptq
function M.add_visual_selection(tags)
  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  -- Join lines and escape for shell
  local text = table.concat(lines, "\n")

  -- Add context (file path, line numbers)
  local file_path = vim.fn.expand("%:p")
  local context = string.format(
    "Review this code from %s (lines %d-%d):\n\n%s",
    file_path, start_pos[2], end_pos[2], text
  )

  -- Call promptq
  local tag_str = tags or "#code-review"
  local cmd = string.format("promptq add %s %s",
    vim.fn.shellescape(context),
    vim.fn.shellescape(tag_str))

  vim.fn.system(cmd)
  vim.notify("Added to promptq", vim.log.levels.INFO)
end

-- Quick send using template
function M.add_from_template(template_name, vars)
  local var_args = ""
  if vars then
    for k, v in pairs(vars) do
      var_args = var_args .. " " .. k .. "=" .. vim.fn.shellescape(v)
    end
  end

  local cmd = string.format("promptq template add %s%s",
    template_name, var_args)

  vim.fn.system(cmd)
  vim.notify("Added from template: " .. template_name, vim.log.levels.INFO)
end

-- Send next prompt
function M.send()
  vim.fn.system("promptq send")
  vim.notify("Sent prompt to Claude", vim.log.levels.INFO)
end

-- Interactive selection with fzf
function M.select_send()
  vim.fn.system("promptq select-send")
end

return M
```

### Keybindings

Add to `~/.config/nvim/lua/config/keymaps.lua`:

```lua
local promptq = require("promptq")

-- Visual mode: add selection to queue
vim.keymap.set("v", "<leader>qa", function()
  promptq.add_visual_selection("#code-review")
end, { desc = "Add to promptq" })

-- Normal mode: send next prompt
vim.keymap.set("n", "<leader>qs", promptq.send,
  { desc = "Send promptq" })

-- Normal mode: interactive send
vim.keymap.set("n", "<leader>qi", promptq.select_send,
  { desc = "Interactive promptq send" })

-- Quick template shortcuts
vim.keymap.set("n", "<leader>qe", function()
  local word = vim.fn.expand("<cword>")
  local filetype = vim.bo.filetype
  promptq.add_from_template("explain-concept", {
    CONCEPT = word,
    LANGUAGE = filetype
  })
end, { desc = "Explain concept" })
```

### Telescope Integration (Optional)

```lua
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function M.telescope_picker()
  -- Parse queue with jq
  local queue_file = vim.fn.expand("~/.config/promptq/queue.jsonl")
  local results = {}

  for line in io.lines(queue_file) do
    local entry = vim.fn.json_decode(line)
    table.insert(results, {
      text = entry.text,
      tags = entry.tags,
      display = entry.text:sub(1, 80)
    })
  end

  pickers.new({}, {
    prompt_title = "promptq Queue",
    finder = finders.new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.text
        }
      end
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        -- Send selected prompt
        -- Implementation depends on queue manipulation
      end)
      return true
    end
  }):find()
end
```

## VS Code Integration

### Using Tasks API

Create `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "promptq: Add Selection",
      "type": "shell",
      "command": "promptq",
      "args": [
        "add",
        "${selectedText}",
        "#code-review"
      ],
      "presentation": {
        "reveal": "silent",
        "panel": "shared"
      }
    },
    {
      "label": "promptq: Send Next",
      "type": "shell",
      "command": "promptq",
      "args": ["send"],
      "presentation": {
        "reveal": "always"
      }
    },
    {
      "label": "promptq: Interactive Send",
      "type": "shell",
      "command": "promptq",
      "args": ["select-send"],
      "presentation": {
        "reveal": "always"
      }
    }
  ]
}
```

### Keybindings

Add to `keybindings.json`:

```json
[
  {
    "key": "ctrl+shift+q a",
    "command": "workbench.action.tasks.runTask",
    "args": "promptq: Add Selection",
    "when": "editorHasSelection"
  },
  {
    "key": "ctrl+shift+q s",
    "command": "workbench.action.tasks.runTask",
    "args": "promptq: Send Next"
  }
]
```

### Extension Implementation (TypeScript)

For a more robust integration, create a VS Code extension:

```typescript
import * as vscode from 'vscode';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

export function activate(context: vscode.ExtensionContext) {
  // Add selection to queue
  let addCommand = vscode.commands.registerCommand(
    'promptq.addSelection',
    async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor) return;

      const selection = editor.document.getText(editor.selection);
      const filePath = editor.document.fileName;
      const startLine = editor.selection.start.line + 1;
      const endLine = editor.selection.end.line + 1;

      const context = `Review this code from ${filePath} (lines ${startLine}-${endLine}):\n\n${selection}`;

      try {
        await execAsync(`promptq add "${context.replace(/"/g, '\\"')}" "#code-review"`);
        vscode.window.showInformationMessage('Added to promptq');
      } catch (error) {
        vscode.window.showErrorMessage(`Failed: ${error}`);
      }
    }
  );

  // Send next prompt
  let sendCommand = vscode.commands.registerCommand(
    'promptq.send',
    async () => {
      try {
        const { stdout } = await execAsync('promptq send');
        vscode.window.showInformationMessage(stdout);
      } catch (error) {
        vscode.window.showErrorMessage(`Failed: ${error}`);
      }
    }
  );

  context.subscriptions.push(addCommand, sendCommand);
}
```

## Raycast Extension

### Script Command

Create `~/Library/Application Support/Raycast/Scripts/promptq-add.sh`:

```bash
#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Add to promptq
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝
# @raycast.argument1 { "type": "text", "placeholder": "Prompt" }
# @raycast.argument2 { "type": "text", "placeholder": "Tags (optional)", "optional": true }

# Documentation:
# @raycast.description Add prompt to promptq
# @raycast.author Your Name

promptq add "$1" "${2:-}"
echo "Added to promptq"
```

### Quick Send Script

```bash
#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Send promptq
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 📤

promptq send
```

### Template-based Script

```bash
#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Explain Concept
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💡
# @raycast.argument1 { "type": "text", "placeholder": "Concept" }
# @raycast.argument2 { "type": "text", "placeholder": "Language" }

promptq template add explain-concept \
  "CONCEPT=$1" \
  "LANGUAGE=$2"

echo "Added: Explain $1 in $2"
```

## Alfred Workflow

### Workflow Structure

1. **Keyword Trigger**: `pqa` (promptq add)
2. **Run Script**:
```bash
query="$1"
promptq add "$query" "#quick"
echo "Added: $query"
```

3. **Keyword Trigger**: `pqs` (promptq send)
4. **Run Script**:
```bash
promptq send
```

## Command Line Integrations

### Zsh Function

Add to `~/.zshrc` or `~/.config/zsh/functions.zsh`:

```bash
# Quick add from clipboard
pqc() {
  local text=$(pbpaste)
  promptq add "$text" "${1:-#clipboard}"
  echo "Added clipboard content to promptq"
}

# Add with custom tags
pqa() {
  local text="$1"
  shift
  local tags="$*"
  promptq add "$text" "$tags"
}

# Interactive send with fzf preview
pqi() {
  promptq select-send
}
```

### Git Integration

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Auto-queue commit message for review

COMMIT_MSG=$(git diff --cached --name-status)
promptq add "Review these changes:\n$COMMIT_MSG" "#git #review"
```

## tmux Integration

### Status Bar Integration

Already implemented in `tmux-claude-usage.sh`, but you could add:

```bash
# Show queue count in status bar
QUEUE_COUNT=$(promptq count 2>/dev/null || echo "0")
echo "Q:$QUEUE_COUNT"
```

### tmux Keybinding

Add to `.tmux.conf`:

```tmux
# Send promptq with prefix + Q
bind-key Q run-shell "promptq send"

# Interactive selection
bind-key C-q run-shell "tmux popup -E 'promptq select-send'"
```

## API Design

For programmatic access, `promptq` exposes a simple JSON API through its JSONL files:

### Adding Prompts (Shell)

```bash
# Direct JSONL write (bypasses promptq CLI)
echo '{"ts":"'$(date -Iseconds)'","text":"My prompt","tags":["custom"]}' \
  >> ~/.config/promptq/queue.jsonl
```

### Reading Queue (jq)

```bash
# Get all prompts with specific tag
jq -r 'select(.tags[] == "urgent") | .text' \
  ~/.config/promptq/queue.jsonl

# Count by tag
jq -r '.tags[]' ~/.config/promptq/queue.jsonl | \
  sort | uniq -c | sort -rn
```

## Best Practices

1. **Context is Key**: Always include file path, line numbers, or other context
2. **Use Tags**: Consistent tagging helps with filtering and organization
3. **Templates for Common Tasks**: Create templates for repeated patterns
4. **Editor Integration**: Bind to easy-to-remember keys (suggest `<leader>q*`)
5. **Clipboard Fallback**: Remember that `promptq send` falls back to clipboard if tmux isn't available

## Future Enhancements

- MCP protocol integration for direct IDE communication
- Webhook support for remote triggers
- Priority queue with weights
- Scheduled sends with cron integration
- Multi-user queue sharing
