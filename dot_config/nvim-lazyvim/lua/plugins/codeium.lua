-- Codeium: Free AI-powered code completion (GitHub Copilot alternative)
-- Completely free for individual use with unlimited completions
--
-- Setup:
--   1. Open Neovim
--   2. Run :Codeium Auth
--   3. Copy token from browser and paste into Neovim
--   4. Start coding!
--
-- Usage:
--   - Tab: Accept suggestion
--   - Ctrl-]: Next suggestion
--   - :Codeium Chat: Open AI chat
--   - :Codeium Toggle: Enable/disable completions
--
return {
  {
    "Exafunction/codeium.nvim",
    event = "InsertEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        enable_chat = true,
      })
    end,
  },
}
