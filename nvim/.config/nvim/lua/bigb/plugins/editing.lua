return {
    { "echasnovski/mini.pairs", event = "InsertEnter", opts = {} },
    { "numToStr/Comment.nvim",  event = "BufReadPost", opts = {} },

    -- Mini Nvim
    { "echasnovski/mini.nvim",  version = false },
    -- File explorer (this works properly with oil unlike nvim-tree)
    {
        'echasnovski/mini.files',
        config = function()
            local MiniFiles = require("mini.files")
            MiniFiles.setup({
                mappings = {
                    go_in = "<CR>", -- Map both Enter and L to enter directories or open files
                    go_in_plus = "L",
                    go_out = "_",
                    go_out_plus = "H",
                },
            })
            vim.keymap.set("n", "<leader>ee", function() MiniFiles.open() end,
                { desc = "Explorer (mini.files)" })
            vim.keymap.set("n", "<leader>ef", function()
                MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
                MiniFiles.reveal_cwd()
            end, { desc = "Explorer at current file" })
            vim.keymap.set("n", "<leader>eo", "<cmd>Oil<CR>", { desc = "Explorer (oil)" })
        end,
    },
    -- Surround
    {
        "echasnovski/mini.surround",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            custom_surroundings = nil,
            -- INFO:
            -- saiw surround with no whitespace
            -- saw surround with whitespace
            mappings = {
                add = 'sa',            -- Add surrounding in Normal and Visual modes
                delete = 'ds',         -- Delete surrounding
                find = 'sf',           -- Find surrounding (to the right)
                find_left = 'sF',      -- Find surrounding (to the left)
                highlight = 'sh',      -- Highlight surrounding
                -- NOTE: was 'ca', which shadowed the builtin `ca` text object
                -- (caw / ca" / cap all broke). 'sr' keeps the s-prefix family.
                replace = 'sr',        -- Replace surrounding
                update_n_lines = 'sn', -- Update `n_lines`

                suffix_last = 'l',     -- Suffix to search with "prev" method
                suffix_next = 'n',     -- Suffix to search with "next" method
            },
        },
    },
    -- Get rid of whitespace
    {
        "echasnovski/mini.trailspace",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local miniTrailspace = require("mini.trailspace")

            miniTrailspace.setup({
                only_in_normal_buffers = true,
            })
            vim.keymap.set("n", "<leader>cw", function() miniTrailspace.trim() end,
                { desc = "Trim trailing whitespace" })

            -- Ensure highlight never reappears by removing it on CursorMoved
            vim.api.nvim_create_autocmd("CursorMoved", {
                pattern = "*",
                callback = function()
                    require("mini.trailspace").unhighlight()
                end,
            })
        end,
    },
}
