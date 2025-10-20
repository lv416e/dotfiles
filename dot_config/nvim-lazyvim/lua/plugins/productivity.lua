-- Productivity plugins (all free and open-source)
return {
  -- Oil.nvim: Edit your filesystem like a buffer
  -- Usage: :Oil to open file explorer in current directory
  -- dd to delete, yy to copy, p to paste - Vim-like operations!
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = false, -- Keep neo-tree as default
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      view_options = {
        show_hidden = true,
      },
    },
    keys = {
      { "<leader>fo", "<cmd>Oil<cr>", desc = "Open Oil file explorer" },
    },
  },

  -- Conform.nvim: Lightweight yet powerful formatter
  -- Formats code on save with multiple formatter support
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        sh = { "shfmt" },
        zsh = { "shfmt" },
        rust = { "rustfmt" },
        go = { "gofmt" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -- Noice.nvim: Completely replaces UI for messages, cmdline, and popupmenu
  -- Makes Neovim's UI more modern and beautiful
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    },
  },
}
