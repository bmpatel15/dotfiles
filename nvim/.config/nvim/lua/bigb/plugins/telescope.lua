return {
    "nvim-telescope/telescope.nvim",
    branch = "master", -- using master to fix issues with deprecated to definition warnings
    -- '0.1.x' for stable ver.
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
        "andrew-george/telescope-themes",
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")

        telescope.setup({
            defaults = {
                path_display = { "smart" },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                    },
                },
            },
            extensions = {
                themes = {
                    enable_previewer = true,
                    enable_live_preview = true,
                    persist = {
                        enabled = true,
                        -- The extension writes `vim.cmd("colorscheme <name>")`
                        -- here on select. The old path (lua/colorscheme.lua)
                        -- was never loaded by anything, so switching a theme
                        -- silently reset on restart. colorscheme.lua now
                        -- dofile()s this exact path after setting the default.
                        path = vim.fn.stdpath("config") .. "/lua/bigb/current-theme.lua",
                    },
                },
            },
        })

        -- Extensions must load AFTER setup(), otherwise their `extensions` config is discarded
        telescope.load_extension("fzf")
        telescope.load_extension("themes")

        -- Keymaps
        local map = vim.keymap.set

        -- file/find
        map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
        map("n", "<leader>,", builtin.buffers, { desc = "Switch buffer" })

        -- search
        map("n", "<leader>sW", function()
            builtin.grep_string({ search = vim.fn.expand("<cWORD>") })
        end, { desc = "Grep WORD under cursor" })
        map("n", "<leader>sb", builtin.current_buffer_fuzzy_find, { desc = "Search in buffer" })
        map("n", "<leader>sh", builtin.help_tags, { desc = "Help pages" })
        map("n", "<leader>sk", builtin.keymaps, { desc = "Keymaps" })
        map("n", "<leader>sc", builtin.commands, { desc = "Commands" })
        map("n", "<leader>sm", builtin.marks, { desc = "Marks" })
        map("n", "<leader>sd", builtin.diagnostics, { desc = "Diagnostics" })

        -- code
        map("n", "<leader>cs", builtin.lsp_document_symbols, { desc = "Document symbols" })
        map("n", "<leader>cS", builtin.lsp_dynamic_workspace_symbols, { desc = "Workspace symbols" })

        -- diagnostics / lists
        map("n", "<leader>xx", builtin.diagnostics, { desc = "Diagnostics list" })
        map("n", "<leader>xX", function()
            builtin.diagnostics({ bufnr = 0 })
        end, { desc = "Buffer diagnostics" })

        -- ui
        map("n", "<leader>ut", "<cmd>Telescope themes<CR>", { desc = "Theme switcher" })
    end,
}
