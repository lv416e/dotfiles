-- Silicon: Create beautiful code screenshots
-- Usage: Select code in visual mode and run :Silicon
-- Requires: brew install silicon
return {
  {
    "michaelrommel/nvim-silicon",
    lazy = true,
    cmd = "Silicon",
    main = "nvim-silicon",
    opts = {
      -- Font settings (use Nerd Font for icons)
      font = "HackGen Console NF",
      -- Theme (matches common editor themes)
      -- Available themes: silicon --list-themes
      -- Popular: "gruvbox-dark", "Dracula", "Nord", "OneHalfDark", "Visual Studio Dark+"
      theme = "Monokai Extended",
      -- Output settings
      output = function()
        local output_dir = vim.fn.expand("~/Pictures/Silicon")
        -- ディレクトリが存在しない場合は作成
        if vim.fn.isdirectory(output_dir) == 0 then
          vim.fn.mkdir(output_dir, "p")
        end
        return output_dir .. "/silicon-" .. os.date("!%Y%m%dT%H%M%S") .. ".png"
      end,
      -- Window controls (macOS style)
      window_title = function()
        return vim.fn.fnamemodify(vim.fn.bufname(vim.fn.bufnr()), ":~:.")
      end,
      -- Line numbers (default is ON, use no_line_number to disable)
      -- no_line_number = false,  -- コメントアウト = 行番号表示
      -- Line number offset (starting line number)
      line_offset = function(args)
        return args.line1
      end,
      -- Padding
      pad_horiz = 80,
      pad_vert = 60,
      -- Shadow
      shadow_blur_radius = 16,
      shadow_offset_x = 8,
      shadow_offset_y = 8,
      -- Round corners (default is ON, use no_round_corner to disable)
      -- no_round_corner = false,  -- コメントアウト = 角を丸くする
      -- Right padding for code
      code_pad_right = 25,
    },
    keys = {
      {
        "<leader>cs",
        function()
          require("nvim-silicon").shoot()
        end,
        mode = "v",
        desc = "Create code screenshot (Silicon)",
      },
    },
  },
}
