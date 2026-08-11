return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "lua", "python", "javascript", "typescript", "tsx",
      "json", "yaml", "markdown", "markdown_inline", "bash",
      "html", "css", "sql", "vim", "vimdoc", "query",
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("bigb_treesitter", { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
        if not lang then return end
        pcall(vim.treesitter.start, ev.buf, lang)
      end,
    })
  end,
}
