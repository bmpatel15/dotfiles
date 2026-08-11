return {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = true,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    ---@module 'render-markdown'
    ft = { "markdown", "norg", "rmd", "org" },
    init = function()
        -- Heading palette, shared by render-markdown's Headline*Bg/Fg groups and
        -- treesitter's @markup.heading.N.markdown. Defined here (once) rather than
        -- in after/ftplugin/markdown.lua so it isn't re-run per buffer.
        local heading_colors = { "#ff757f", "#4fd6be", "#7dcfff", "#ff9e64", "#7aa2f7", "#c0caf5" }
        local heading_fg = "#1F2335"

        -- A `:colorscheme` clears user highlights, so re-apply them on every change
        local function set_markdown_highlights()
            for level, bg in ipairs(heading_colors) do
                vim.api.nvim_set_hl(0, "Headline" .. level .. "Bg", { fg = heading_fg, bg = bg, bold = true })
                vim.api.nvim_set_hl(0, "Headline" .. level .. "Fg", { fg = bg, bold = true })
                vim.api.nvim_set_hl(0, "@markup.heading." .. level .. ".markdown",
                    { fg = heading_fg, bg = bg, bold = true })
            end

            -- Callout accent with no Diagnostic* equivalent. Aether's orange,
            -- kept in sync with .obsidian/snippets/nvim-callouts.css (235,139,84).
            vim.api.nvim_set_hl(0, "RenderMarkdownGoal", { fg = "#eb8b54", bold = true })
        end

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("bigb_markdown_highlights", { clear = true }),
            callback = set_markdown_highlights,
        })
        set_markdown_highlights()
    end,
    opts = {
        restart_highlighter = true,
        heading = {
            sign = false,
            icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
            backgrounds = {
                "Headline1Bg",
                "Headline2Bg",
                "Headline3Bg",
                "Headline4Bg",
                "Headline5Bg",
                "Headline6Bg",
            },
            foregrounds = {
                "Headline1Fg",
                "Headline2Fg",
                "Headline3Fg",
                "Headline4Fg",
                "Headline5Fg",
                "Headline6Fg",
            },
        },
        code = {
            sign = false,
            width = "block",
            right_pad = 1,
        },
        quote = {
            -- Repeat the ▋ bar down every visual row of a soft-wrapped quote,
            -- so callout text stays inside the block instead of falling to
            -- column 0. Needs the showbreak/breakindent combo in win_options.
            repeat_linebreak = true,
        },
        -- Managed by the plugin so they apply to markdown windows only and get
        -- restored on the way out. default == rendered keeps text from shifting
        -- when rendering toggles (e.g. entering insert mode).
        win_options = {
            showbreak      = { default = "  ", rendered = "  " },
            breakindent    = { default = true, rendered = true },
            breakindentopt = { default = "", rendered = "" },
        },
        bullet = {
            -- Turn on / off list bullet rendering
            enabled = true,
        },
        checkbox = {
            -- Turn on / off checkbox state rendering
            enabled = true,
            unchecked = {
                -- Replaces '[ ]' of 'task_list_marker_unchecked'
                icon = "   󰄱 ",
                -- Highlight for the unchecked icon
                highlight = "RenderMarkdownUnchecked",
                -- Highlight for item associated with unchecked checkbox
                scope_highlight = nil,
            },
            checked = {
                -- Replaces '[x]' of 'task_list_marker_checked'
                icon = "   󰱒 ",
                -- Highlight for the checked icon
                highlight = "RenderMarkdownChecked",
                -- Highlight for item associated with checked checkbox
                scope_highlight = nil,
            },
        },
        html = {
            comment = {
                conceal = false,
            },
        },
        -- Callouts. This table MERGES with render-markdown's built-in set, so
        -- every stock type (warning, danger, todo, success, bug, info, ...) keeps
        -- working; these are the ones spelled out so they're easy to retune.
        -- Highlights resolve to Diagnostic* groups: Info=blue, Success=green,
        -- Hint=cyan/purple, Warn=yellow, Error=red, Quote=@markup.quote.
        callout = {
            -- requested set
            note      = { raw = "[!NOTE]",      rendered = "󰋽 Note",      highlight = "RenderMarkdownInfo" },
            quote     = { raw = "[!QUOTE]",     rendered = "󱆨 Quote",     highlight = "RenderMarkdownQuote" },
            question  = { raw = "[!QUESTION]",  rendered = "󰘥 Question",  highlight = "RenderMarkdownWarn" },
            important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
            example   = { raw = "[!EXAMPLE]",   rendered = "󰉹 Example",   highlight = "RenderMarkdownHint" },
            summary   = { raw = "[!SUMMARY]",   rendered = "󰨸 Summary",   highlight = "RenderMarkdownInfo" },
            tip       = { raw = "[!TIP]",       rendered = "󰌶 Tip",       highlight = "RenderMarkdownSuccess" },
            -- not a built-in type, added here
            idea      = { raw = "[!IDEA]",      rendered = "󰛨 Idea",      highlight = "RenderMarkdownSuccess" },

            -- extras that earn their keep in a zettelkasten-style vault
            definition = { raw = "[!DEFINITION]", rendered = "󰗚 Definition", highlight = "RenderMarkdownInfo" },
            insight    = { raw = "[!INSIGHT]",    rendered = "󰧑 Insight",    highlight = "RenderMarkdownHint" },
            source     = { raw = "[!SOURCE]",     rendered = "󰈙 Source",     highlight = "RenderMarkdownQuote" },
            goal       = { raw = "[!GOAL]",       rendered = "󰄴 Goal",       highlight = "RenderMarkdownGoal" },
        },
    },
}
