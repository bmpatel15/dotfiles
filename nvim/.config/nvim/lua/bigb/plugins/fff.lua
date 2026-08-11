-- fff indexes one directory at a time, so the project-wide maps anchor it to
-- the project root instead of whatever cwd happens to be.
local function find_in_root()
    require("fff").find_files_in_dir(require("bigb.util").project_root())
end

return {
    "dmtrKovalenko/fff.nvim",
    enabled = true,
    build = function()
        -- this will download prebuild binary or try to use existing rustup toolchain to build from source
        -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
        require("fff.download").download_or_build_binary()
    end,
    lazy = false,
    config = function()
        require("fff").setup({
            title = 'Find Files', -- Window title
            max_results = 100,    -- Maximum search results to display
            max_threads = 4,      -- Maximum threads for fuzzy search
            lazy_sync = true,

            prompt = '🛸 ', -- Input prompt symbol
            layout = {
                width = 0.75, -- Window width as fraction of screen
                height = 0.85, -- Window height as fraction of screen
                prompt_position = 'bottom', -- or 'top'
                preview_position = 'right', -- or 'left', 'right', 'top', 'bottom'
                preview_size = 0.5,
                flex = false,
            },
            preview = {
                enabled = true,
                max_size = 10 * 1024 * 1024, -- skip previewing files larger than 10MB
                chunk_size = 8192,
                binary_file_threshold = 1024,
                line_numbers = false,
                wrap_lines = false,
            },
            keymaps = {
                close = { '<C-c>', '<Esc>' },
                select = '<CR>',
                select_split = '<C-s>',
                select_vsplit = '<C-v>',
                select_tab = '<C-t>',
                -- Multiple bindings supported
                move_up = { '<Up>', '<C-p>', '<C-k>' },
                move_down = { '<Down>', '<C-n>', '<C-j>' },
                preview_scroll_up = '<C-u>',
                preview_scroll_down = '<C-d>',
            },
            git = {
                status_text_color = true, -- Enable git status colors on filename text
            },
            -- Highlight groups
            hl = {
                border = 'FloatBorder',
                normal = 'Normal',
                cursor = 'CursorLine',
                matched = 'IncSearch',
                title = 'Title',
                prompt = 'Question',
                frecency = 'Number',
                debug = 'Comment',
                git_staged = 'FFFGitStaged',       -- Files staged for commit
                git_modified = 'FFFGitModified',   -- Modified unstaged files
                git_deleted = 'FFFGitDeleted',     -- Deleted files
                git_renamed = 'FFFGitRenamed',     -- Renamed files
                git_untracked = 'FFFGitUntracked', -- New untracked files
                git_ignored = 'FFFGitIgnored',     -- Git-ignored files
            },
            frecency = {
                enabled = true,
                db_path = vim.fn.stdpath('cache') .. '/fff_nvim',
            },
            history = {
                enabled = true,
                db_path = vim.fn.stdpath('data') .. '/fff_queries',
                min_combo_count = 3,                -- file will get a boost if it was selected 3 in a row times per specific query
                combo_boost_score_multiplier = 100, -- Score multiplier for combo matches
            },
            -- Debug options
            debug = {
                show_scores = false, -- Toggle with F2 or :FFFDebug
            },
        })
    end,
    keys = {
        { "<leader>ff",      find_in_root, desc = "Find files (project root)" },
        { "<leader><space>", find_in_root, desc = "Find files (project root)" },
        {
            "<leader>fd",
            function() require("fff").find_files() end,
            desc = "Find files (cwd only)",
        },
        {
            "<leader>fg",
            function() require("fff").find_in_git_root() end,
            desc = "Find files in git root",
        },
        {
            "<leader>fc",
            function() require("fff").find_files_in_dir(vim.fn.stdpath("config")) end,
            desc = "Find files in nvim config",
        },
        {
            "<leader>fo",
            function() require("fff").find_files_in_dir(require("bigb.util").vault) end,
            desc = "Find files in Obsidian vault",
        },
        {
            "<leader>ss",
            function() require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } }) end,
            desc = "Grep project",
        },
        {
            "<leader>/",
            function() require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } }) end,
            desc = "Grep project",
        },
        {
            "<leader>sw",
            function() require("fff").live_grep_under_cursor() end,
            mode = { "n", "v" },
            desc = "Grep word under cursor",
        },
        {
            "<leader>sr",
            function() require("fff").resume() end,
            desc = "Resume last picker",
        },
    },
}
