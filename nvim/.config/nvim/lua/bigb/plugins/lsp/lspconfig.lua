return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("bigb_lsp", { clear = true }),
      callback = function(ev)
        local function map(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
        end
        map("gd", vim.lsp.buf.definition, "Definition")
        map("gD", vim.lsp.buf.declaration, "Declaration")
        map("gi", vim.lsp.buf.implementation, "Implementation")
        map("gr", vim.lsp.buf.references, "References")
        map("gy", vim.lsp.buf.type_definition, "Type definition")
        map("K", vim.lsp.buf.hover, "Hover docs")

        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
        map("<leader>cl", function()
          vim.cmd("lsp restart")
          vim.notify("LSP restarted", vim.log.levels.INFO)
        end, "Restart LSP")
      end,
    })
    vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = { diagnostics = { globals = { "vim" } } },
      },
    })

    vim.lsp.config("basedpyright", {
      settings = {
        basedpyright = {
          disableOrganizeImports = true,
          analysis = { typeCheckingMode = "standard" },
        },
      },
    })

    -- bash-language-server shells out to `shellcheck` for diagnostics when it
    -- is on PATH (mason.nvim prepends its bin dir), which is where most of the
    -- value is: it explains quoting and word-splitting mistakes as you type.
    vim.lsp.config("bashls", {
      settings = {
        bashIde = {
          -- default globs only .sh; also lint files with no extension that
          -- start with a bash shebang
          globPattern = "*@(.sh|.inc|.bash|.command)",
        },
      },
    })

    vim.lsp.enable({ "lua_ls", "basedpyright", "ruff", "ts_ls", "bashls" })
  end,
}
