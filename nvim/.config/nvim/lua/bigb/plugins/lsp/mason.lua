return {
  "mason-org/mason.nvim",
  lazy = false,
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup()

    -- Language servers. mason-lspconfig maps these lspconfig names to their
    -- Mason package names (bashls -> bash-language-server, etc).
    require("mason-lspconfig").setup({
      automatic_enable = false,
      ensure_installed = {
        "lua_ls",
        "basedpyright",
        "ruff",
        "ts_ls",
        "bashls", -- Bash: completion + shellcheck diagnostics
      },
    })

    -- Standalone CLI tools. mason-lspconfig only handles servers, so formatters
    -- and linters need their own installer -- previously stylua and prettierd
    -- were referenced by conform but never installed, so those filetypes
    -- silently fell back to LSP formatting.
    require("mason-tool-installer").setup({
      ensure_installed = {
        "stylua",     -- lua formatter
        "prettierd",  -- js/ts formatter
        "shfmt",      -- bash formatter
        "shellcheck", -- bash linter; bashls picks it up off PATH automatically
      },
      auto_update = false,
      run_on_start = true,
    })
  end,
}
