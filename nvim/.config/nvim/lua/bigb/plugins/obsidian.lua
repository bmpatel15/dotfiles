local VAULT = require("bigb.util").vault
local TEMPLATE_DIR = "09 - Templates"

return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    -- Only load inside the vault, so obsidian.nvim never touches other markdown
    event = {
        "BufReadPre " .. VAULT .. "/**/*.md",
        "BufNewFile " .. VAULT .. "/**/*.md",
    },
    cmd = "Obsidian",
    dependencies = { "nvim-lua/plenary.nvim" },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
        legacy_commands = false, -- only `:Obsidian <subcmd>`, no `:ObsidianToday` etc.

        workspaces = {
            { name = "BigB-PKM", path = VAULT },
        },

        -- render-markdown.nvim owns all in-buffer rendering; leaving this on
        -- means two plugins draw bullets/checkboxes over each other
        ui = { enable = false },

        picker = { name = "telescope.nvim" },

        -- Mirrors .obsidian/app.json: newFileLocation=folder, "02 - Fleeting Notes"
        notes_subdir = "02 - Fleeting Notes",
        new_notes_location = "notes_subdir",

        -- Vault filenames are human-readable ("SELECT Statement in SQL.md"),
        -- not zettel IDs, so keep the title and only strip illegal characters
        note_id_func = function(title)
            if title ~= nil and title ~= "" then
                return (title:gsub('[/\\:*?"<>|]', ""))
            end
            return os.date("%Y-%m-%d-") .. tostring(os.time())
        end,

        -- Vault frontmatter is a hand-rolled Dataview schema (type/created/status/...).
        -- Leaving this enabled rewrites and re-sorts frontmatter on every save.
        frontmatter = { enabled = false },

        templates = {
            folder = TEMPLATE_DIR,
            date_format = "YYYY-MM-DD",
            time_format = "HH:mm",
        },

        -- Mirrors .obsidian/daily-notes.json
        daily_notes = {
            folder = "01 - Daily Notes",
            date_format = "YYYY-MM-DD",
            template = "Daily Note Template.md",
            default_tags = { "daily-note" }, -- vault uses the singular tag
            workdays_only = false,           -- vault has weekend dailies
        },

        -- Mirrors .obsidian/app.json attachmentFolderPath
        attachments = { folder = "08 - Attachments/media" },

        -- `useMarkdownLinks: false` in app.json
        link = { style = "wiki", format = "shortest" },

        -- render-markdown.nvim only styles [ ] and [x], so don't cycle through
        -- the ~ ! > states it would leave unrendered
        checkbox = { order = { " ", "x" } },

        completion = { min_chars = 2 },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)

        --- Open a new task line relative to the cursor and leave you typing in it.
        ---@param above boolean
        local function new_task(above)
            local row = vim.api.nvim_win_get_cursor(0)[1]
            local indent = vim.api.nvim_get_current_line():match("^%s*") or ""
            local text = indent .. "- [ ] "
            local at = above and row - 1 or row
            vim.api.nvim_buf_set_lines(0, at, at, false, { text })
            vim.api.nvim_win_set_cursor(0, { at + 1, #text })
            vim.cmd("startinsert!")
        end

        -- Note-local keymaps: these only make sense inside a vault note, so they
        -- are attached per buffer instead of living in the global `keys` table.
        vim.api.nvim_create_autocmd("User", {
            group = vim.api.nvim_create_augroup("bigb_obsidian_note_keys", { clear = true }),
            pattern = "ObsidianNoteEnter",
            callback = function(ev)
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = "Obsidian: " .. desc })
                end

                -- Links (<CR> already does this via smart_action; these are explicit)
                map("n", "<leader>of", "<cmd>Obsidian follow_link<cr>", "follow link")
                map("n", "<leader>oF", "<cmd>Obsidian follow_link vsplit<cr>", "follow link in vsplit")
                map("n", "<leader>oh", "<cmd>Obsidian follow_link hsplit<cr>", "follow link in hsplit")

                -- Tasks -- normal + visual. `checkbox.create_new` is on, so this
                -- also turns a plain line into `- [ ] line`.
                map({ "n", "v" }, "<leader>ot", "<cmd>Obsidian toggle_checkbox<cr>", "toggle task")
                map("n", "<leader>oa", function() new_task(false) end, "add task below")
                map("n", "<leader>oA", function() new_task(true) end, "add task above")

                -- Tasks -- insert mode. Plain typed sequences rather than buffer
                -- edits: editing the buffer mid-insert desyncs the cursor and
                -- undo block. <End> first so it always starts a fresh line, and
                -- 'autoindent' carries the list indent across the <CR>.
                map("i", "<M-t>", "- [ ] ", "insert task marker")
                map("i", "<M-CR>", "<End><CR>- [ ] ", "new task line")
            end,
        })

        -- Vault templates use Templater syntax (`<% tp.date.now("YYYY-MM-DD") %>`),
        -- which obsidian.nvim does not expand -- it only handles `{{...}}`. Expand
        -- the tokens ourselves when a note is opened, skipping the template files.
        vim.api.nvim_create_autocmd("User", {
            group = vim.api.nvim_create_augroup("bigb_obsidian_templater", { clear = true }),
            pattern = "ObsidianNoteEnter",
            callback = function()
                local buf = vim.api.nvim_get_current_buf()
                local name = vim.api.nvim_buf_get_name(buf)
                if name:find(TEMPLATE_DIR, 1, true) then return end

                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                local changed = false
                for i, line in ipairs(lines) do
                    local new = line:gsub('<%%%s*tp%.date%.now%("([^"]*)"%)%s*%%>', function(fmt)
                        return require("obsidian.util").format_date(os.time(), fmt)
                    end)
                    if new ~= line then
                        lines[i] = new
                        changed = true
                    end
                end

                if changed then
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                end
            end,
        })
    end,
    keys = {
        { "<leader>oo", "<cmd>Obsidian quick_switch<cr>",     desc = "Obsidian: quick switch note" },
        { "<leader>os", "<cmd>Obsidian search<cr>",           desc = "Obsidian: grep vault" },
        { "<leader>on", "<cmd>Obsidian new<cr>",              desc = "Obsidian: new note" },
        { "<leader>oT", "<cmd>Obsidian new_from_template<cr>", desc = "Obsidian: new note from template" },
        { "<leader>od", "<cmd>Obsidian today<cr>",            desc = "Obsidian: today's daily note" },
        { "<leader>oy", "<cmd>Obsidian yesterday<cr>",        desc = "Obsidian: yesterday's daily note" },
        { "<leader>om", "<cmd>Obsidian tomorrow<cr>",         desc = "Obsidian: tomorrow's daily note" },
        { "<leader>oD", "<cmd>Obsidian dailies<cr>",          desc = "Obsidian: browse daily notes" },
        { "<leader>ob", "<cmd>Obsidian backlinks<cr>",        desc = "Obsidian: backlinks" },
        { "<leader>ol", "<cmd>Obsidian links<cr>",            desc = "Obsidian: links in note" },
        -- `#` is the tag sigil; <leader>ot is the note-local task toggle
        { "<leader>o#", "<cmd>Obsidian tags<cr>",             desc = "Obsidian: search tags" },
        { "<leader>oc", "<cmd>Obsidian toc<cr>",              desc = "Obsidian: table of contents" },
        { "<leader>op", "<cmd>Obsidian paste_img<cr>",        desc = "Obsidian: paste image" },
        { "<leader>or", "<cmd>Obsidian rename<cr>",           desc = "Obsidian: rename note + update links" },
        { "<leader>oi", "<cmd>Obsidian template<cr>",         desc = "Obsidian: insert template" },
    },
}
