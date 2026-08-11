return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      -- shfmt takes its indent width from the buffer's shiftwidth (conform
      -- passes -i automatically), which after/ftplugin/sh.lua sets to 2.
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat then return end
      if vim.bo[bufnr].filetype == "markdown" then return end
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
  },
  keys = {
    { "<leader>cf", function() require("conform").format({ async = true }) end,
      mode = { "n", "v" }, desc = "Format buffer" },
    { "<leader>uf", function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify("Autoformat on save " .. (vim.g.disable_autoformat and "off" or "on"),
          vim.log.levels.INFO)
      end, desc = "Toggle autoformat on save" },
  },
}
