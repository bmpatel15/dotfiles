return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = 200, -- ms before the popup appears
        spec = {
            { "<leader>b", group = "buffer",      icon = "󰓩 " },
            { "<leader>c", group = "code",        icon = " " },
            { "<leader>e", group = "explorer",    icon = " " },
            { "<leader>f", group = "file/find",   icon = " " },
            { "<leader>h", group = "harpoon",     icon = "󱡀 " },
            -- <leader>m (markdown) is registered buffer-locally in
            -- after/ftplugin/markdown.lua so it only appears in markdown files
            { "<leader>o", group = "obsidian",    icon = "󱓧 " },
            { "<leader>r", group = "repl",        icon = " " },
            { "<leader>s", group = "search",      icon = " " },
            { "<leader>t", group = "tab",         icon = "󰓩 " },
            { "<leader>u", group = "ui toggle",   icon = "󰔡 " },
            { "<leader>w", group = "window",      icon = " " },
            { "<leader>x", group = "diagnostics", icon = " " },
        },
    },
    keys = {
        {
            "<leader>?",
            function() require("which-key").show({ global = true }) end,
            desc = "Show all keymaps",
        },
    },
}
