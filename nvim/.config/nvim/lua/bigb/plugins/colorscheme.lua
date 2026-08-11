return {
    {
        "bjarneo/aether.nvim",
        branch = "v3",
        name = "aether",
        lazy = false,
        priority = 1000,
        opts = {
            colors = {
                bg = "#060B1E",
                dark_bg = "#040816",
                darker_bg = "#030610",
                lighter_bg = "#131a3a",
                fg = "#ffcead",
                dark_fg = "#6d7db6",
                light_fg = "#c9b8a6",
                bright_fg = "#ffcead",
                muted = "#6d7db6",
                red = "#ED5B5A",
                yellow = "#E9BB4F",
                orange = "#eb8b54",
                green = "#92a593",
                cyan = "#a3bfd1",
                blue = "#7d82d9",
                magenta = "#c89dc1",
                brown = "#75452a",
                accent = "#7d82d9",
                selection = "#252e56",
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- <leader>ut (Telescope themes) writes the picked theme here as a
            -- one-line `vim.cmd("colorscheme X")`. Load it after the default so
            -- a switch survives a restart; absent or broken file just leaves
            -- aether in place.
            local persisted = vim.fn.stdpath("config") .. "/lua/bigb/current-theme.lua"
            if vim.uv.fs_stat(persisted) then
                pcall(dofile, persisted)
            end
        end,
    },
}
