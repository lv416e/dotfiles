-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ============================================================================
-- Terminal Mode Paste Fix
-- ============================================================================
-- Enable paste in terminal mode using Ctrl+Shift+V (common terminal shortcut)
-- Note: Cmd+V may not work in terminal mode due to macOS/tmux/Neovim layers
vim.keymap.set("t", "<C-S-v>", function()
  local reg_content = vim.fn.getreg("+")
  if reg_content and #reg_content > 0 then
    -- Send clipboard content to terminal
    vim.api.nvim_paste(reg_content, true, -1)
  end
end, { desc = "Paste in terminal mode (Ctrl+Shift+V)" })

-- Alternative: Use Ctrl+V in terminal mode
vim.keymap.set("t", "<C-v>", function()
  local reg_content = vim.fn.getreg("+")
  if reg_content and #reg_content > 0 then
    vim.api.nvim_paste(reg_content, true, -1)
  end
end, { desc = "Paste in terminal mode (Ctrl+V)" })

-- Manual bracketed paste mode reset (for debugging)
vim.keymap.set("n", "<leader>pr", function()
  vim.fn.system("printf '\\e[?2004l'")
  vim.notify("Bracketed paste mode reset", vim.log.levels.INFO)
end, { desc = "Reset Bracketed Paste Mode" })
