return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status")

        -- Ethereal palette, straight from the Omarchy theme's colors.toml
        local colors = {
            bg         = "#060B1E",
            dark_bg    = "#040816",
            darker_bg  = "#030610",
            lighter_bg = "#131a3a",
            fg         = "#ffcead",
            light_fg   = "#c9b8a6",
            muted      = "#6d7db6",
            red        = "#ED5B5A",
            yellow     = "#E9BB4F",
            orange     = "#eb8b54",
            green      = "#92a593",
            cyan       = "#a3bfd1",
            blue       = "#7d82d9",
            magenta    = "#c89dc1",
            selection  = "#252e56",
        }

        local my_lualine_theme = {
            normal = {
                a = { fg = colors.bg, bg = colors.blue, gui = "bold" },
                b = { fg = colors.light_fg, bg = colors.lighter_bg },
                c = { fg = colors.muted, bg = colors.darker_bg },
            },
            insert = {
                a = { fg = colors.bg, bg = colors.green, gui = "bold" },
                b = { fg = colors.light_fg, bg = colors.lighter_bg },
                c = { fg = colors.muted, bg = colors.darker_bg },
            },
            visual = {
                a = { fg = colors.bg, bg = colors.magenta, gui = "bold" },
                b = { fg = colors.light_fg, bg = colors.lighter_bg },
                c = { fg = colors.muted, bg = colors.darker_bg },
            },
            replace = {
                a = { fg = colors.bg, bg = colors.red, gui = "bold" },
                b = { fg = colors.light_fg, bg = colors.lighter_bg },
                c = { fg = colors.muted, bg = colors.darker_bg },
            },
            command = {
                a = { fg = colors.bg, bg = colors.yellow, gui = "bold" },
                b = { fg = colors.light_fg, bg = colors.lighter_bg },
                c = { fg = colors.muted, bg = colors.darker_bg },
            },
            terminal = {
                a = { fg = colors.bg, bg = colors.cyan, gui = "bold" },
                b = { fg = colors.light_fg, bg = colors.lighter_bg },
                c = { fg = colors.muted, bg = colors.darker_bg },
            },
            inactive = {
                a = { fg = colors.muted, bg = colors.darker_bg, gui = "bold" },
                b = { fg = colors.muted, bg = colors.darker_bg },
                c = { fg = colors.muted, bg = colors.darker_bg },
            },
        }

        local mode = {
            "mode",
            fmt = function(str)
                return "" .. str
            end,
        }

        local diff = {
            "diff",
            colored = true,
            symbols = { added = " ", modified = " ", removed = " " },
            diff_color = {
                added    = { fg = colors.green },
                modified = { fg = colors.yellow },
                removed  = { fg = colors.red },
            },
        }

        local filename = {
            "filename",
            file_status = true,
            path = 0,
            color = { fg = colors.fg },
            symbols = { modified = "  ", readonly = "  " },
        }

        local branch = {
            "branch",
            icon = { "", color = { fg = colors.cyan } },
        }

        local diagnostics = {
            "diagnostics",
            sources = { "nvim_lsp" },
            symbols = { error = " ", warn = " ", hint = "󰠠 ", info = " " },
            diagnostics_color = {
                error = { fg = colors.red },
                warn  = { fg = colors.yellow },
                hint  = { fg = colors.blue },
                info  = { fg = colors.cyan },
            },
        }

        lualine.setup({
            options = {
                icons_enabled = true,
                theme = my_lualine_theme,
                globalstatus = true,
                component_separators = { left = "|", right = "|" },
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = { mode },
                lualine_b = { branch },
                lualine_c = { diff, filename, diagnostics },
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = colors.orange },
                    },
                    { "filetype", color = { fg = colors.muted } },
                },
                lualine_y = { { "progress", color = { fg = colors.muted } } },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_c = { { "filename", path = 1, color = { fg = colors.muted } } },
                lualine_x = {},
            },
        })
    end,
}
