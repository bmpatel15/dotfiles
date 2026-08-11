return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    default_file_explorer = true,
    view_options = { show_hidden = true },
  },
  keys = {
    { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
  },
}
