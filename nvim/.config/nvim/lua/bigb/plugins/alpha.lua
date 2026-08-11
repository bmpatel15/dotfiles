return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        local util = require("bigb.util")

        --- Dashboard button that runs a Lua function.
        --- alpha's own `dashboard.button()` only replays keystrokes, so anything
        --- with logic has to be bound directly instead of as a `<cmd>...<CR>`.
        ---@param sc string shortcut key
        ---@param txt string label
        ---@param fn function
        local function button(sc, txt, fn)
            local b = dashboard.button(sc, txt, "")
            b.on_press = fn
            b.opts.keymap = { "n", sc, fn, { noremap = true, silent = true, nowait = true } }
            return b
        end

        -- Set header
        dashboard.section.header.val = {
            "                                                     ",
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
            "                                                     ",
        }

        -- Set menu -- same pickers the <leader> maps use, so muscle memory carries over
        dashboard.section.buttons.val = {
            button("n", "󰝒 > New File", function() vim.cmd("enew") end),
            button("f", "󰱼 > Find File", function()
                require("fff").find_files_in_dir(util.project_root())
            end),
            button("r", "󰋚 > Recent Files", function()
                require("telescope.builtin").oldfiles()
            end),
            button("g", "󰍉 > Find Word", function()
                require("fff").live_grep()
            end),
            button("c", "󰒓 > Config Files", function()
                require("fff").find_files_in_dir(vim.fn.stdpath("config"))
            end),
            button("o", "󱓧 > Obsidian Vault", function()
                require("fff").find_files_in_dir(util.vault)
            end),
            button("l", "󰒲 > Lazy", function() vim.cmd("Lazy") end),
            button("q", "󰐥 > Quit NVIM", function() vim.cmd("qa") end),
        }

        -- Send config to alpha
        alpha.setup(dashboard.opts)

        -- Disable folding on alpha buffer
        vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
    end,
}
