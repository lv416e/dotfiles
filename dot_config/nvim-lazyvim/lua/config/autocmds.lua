-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ============================================================================
-- Terminal Bracketed Paste Mode Fix
-- ============================================================================
-- Claude Code leaves terminal in corrupted bracketed paste mode
-- This disables it automatically when opening terminal buffers
-- Issue: https://github.com/anthropics/claude-code/issues/3134

-- Disable bracketed paste mode when terminal buffer opens
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("disable_bracketed_paste", { clear = true }),
  pattern = "*",
  callback = function()
    -- Wait for terminal to be ready
    vim.defer_fn(function()
      local chan = vim.b.terminal_job_id
      if chan then
        -- Send escape sequence to disable bracketed paste mode
        -- \x1b[?2004l = ESC[?2004l (disable bracketed paste)
        vim.fn.chansend(chan, "\x1b[?2004l")
      end
    end, 100)
  end,
})

-- Reset bracketed paste mode when leaving terminal
vim.api.nvim_create_autocmd("TermLeave", {
  group = vim.api.nvim_create_augroup("terminal_paste_reset", { clear = true }),
  pattern = "*",
  callback = function()
    -- Reset in the parent shell too
    vim.fn.system("printf '\\e[?2004l'")
  end,
})

-- Cleanup when terminal closes
vim.api.nvim_create_autocmd("TermClose", {
  group = vim.api.nvim_create_augroup("cleanup_bracketed_paste", { clear = true }),
  pattern = "*",
  callback = function()
    -- Final cleanup
    vim.fn.system("printf '\\e[?2004l'")
  end,
})
