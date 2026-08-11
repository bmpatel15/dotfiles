-- The AI-engineering inner loop is not "write file, run file" -- it is send a
-- few lines to a live interpreter, look at the shape of the thing, adjust.
-- iron.nvim gives that; venv-selector points basedpyright at the right
-- interpreter so project imports stop showing as unresolved.
return {
    {
        "Vigemus/iron.nvim",
        cmd = { "IronRepl", "IronRestart", "IronFocus", "IronHide" },
        keys = {
            { "<leader>rr", "<cmd>IronRepl<cr>",    desc = "REPL: toggle" },
            { "<leader>rR", "<cmd>IronRestart<cr>", desc = "REPL: restart" },
            { "<leader>rF", "<cmd>IronFocus<cr>",   desc = "REPL: focus" },
            { "<leader>rc", mode = { "n", "v" },    desc = "REPL: send motion/selection" },
            { "<leader>rl", desc = "REPL: send line" },
            { "<leader>rf", desc = "REPL: send file" },
            { "<leader>ru", desc = "REPL: send until cursor" },
            { "<leader>rq", desc = "REPL: exit" },
            { "<leader>rx", desc = "REPL: clear" },
        },
        config = function()
            local iron = require("iron.core")
            local view = require("iron.view")

            iron.setup({
                config = {
                    -- a scratch REPL isn't tied to a file, so sending from
                    -- several buffers reuses one interpreter
                    scratch_repl = true,
                    repl_definition = {
                        python = {
                            command = { "python3" },
                            -- bracketed paste keeps indented blocks (def/for/if)
                            -- from being re-indented into a syntax error
                            format = require("iron.fts.common").bracketed_paste_python,
                        },
                        sh = { command = { "bash" } },
                    },
                    repl_open_cmd = view.split.vertical.botright(0.4),
                },
                keymaps = {
                    toggle_repl = "<leader>rr",
                    restart_repl = "<leader>rR",
                    send_motion = "<leader>rc",
                    visual_send = "<leader>rc",
                    send_file = "<leader>rf",
                    send_line = "<leader>rl",
                    send_until_cursor = "<leader>ru",
                    exit = "<leader>rq",
                    clear = "<leader>rx",
                },
                ignore_blank_lines = true,
            })
        end,
    },

    {
        "linux-cultist/venv-selector.nvim",
        dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
        ft = "python",
        opts = {},
        keys = {
            { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
        },
    },
}
