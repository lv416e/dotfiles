-- Claude Code integration for Neovim
-- Connects to Claude Code CLI using WebSocket MCP protocol
-- Requires: Claude Code CLI installed and logged in with Pro/Max plan
return {
  "coder/claudecode.nvim",
  event = "VeryLazy",
  config = function()
    require("claudecode").setup({
      -- Default settings work out of the box
      -- WebSocket server auto-starts on random port
    })
  end,
  keys = {
    { "<leader>cc", desc = "Claude Code" },
  },
}
