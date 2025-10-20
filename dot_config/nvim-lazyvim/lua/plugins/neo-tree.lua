return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- hidden filesを表示
        hide_dotfiles = false, -- dotfilesを隠さない
        hide_gitignored = false, -- gitignoreされたファイルも表示
      },
    },
  },
}
