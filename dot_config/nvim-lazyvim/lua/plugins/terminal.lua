-- Restore shell keybindings in terminal mode
-- This overrides LazyVim's default Snacks terminal navigation keys
return {
  {
    "snacks.nvim",
    opts = {
      terminal = {
        win = {
          keys = {
            -- Disable Ctrl+hjkl window navigation in terminal mode
            -- This restores shell bindings like:
            -- - Ctrl+K: kill-line
            -- - Ctrl+L: clear screen
            -- - Ctrl+H: backspace
            -- - Ctrl+J: newline/accept
            nav_h = false,
            nav_j = false,
            nav_k = false,
            nav_l = false,
          },
        },
      },
    },
  },
}
