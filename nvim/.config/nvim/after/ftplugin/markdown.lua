local set = vim.opt_local

-- Soft wrap prose: a paragraph stays one physical line in the file, so it can
-- never lose its `> ` callout prefix mid-thought, and it round-trips to the
-- Obsidian app without hard breaks baked in.
set.wrap = true
set.linebreak = true -- break at word boundaries, not mid-word
set.textwidth = 0    -- no hard wrapping
set.spell = true     -- Enable spell checking
-- Scripture study is full of words no English dictionary has (Vachanamrut,
-- Akshar, Purushottam, shloka...). Point the personal dictionary at the config
-- so `zg` additions are permanent and travel with these files; spell/en.utf-8.add
-- is pre-seeded with the standard vocabulary.
set.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
set.spelloptions:append("camel") -- don't flag CamelCase note titles as typos
-- The compiled .add.spl is a build artifact and isn't committed, so build it
-- on first use. Without this a fresh clone ignores the dictionary entirely.
require("bigb.util").ensure_spellfile()

-- Vachanamrut is 273 discourses and Satsang Diksha is 315 shlokas: long,
-- numbered, heading-structured texts. Fold by heading so a note collapses to
-- its outline (zM), and open one section at a time (zR / za).
set.foldmethod = "expr"
set.foldexpr = "v:lua.vim.treesitter.foldexpr()"
set.foldlevel = 99 -- start fully open; folding is opt-in per session
-- t auto-wraps at textwidth, which we no longer want. r/o carry the `> `
-- blockquote leader onto new lines made with <CR> and o/O -- without those,
-- <CR> inside a callout drops you out of it.
set.formatoptions:remove("t")
set.formatoptions:append("ro")
set.smartindent = false

-- With wrap on, j/k jump over whole wrapped paragraphs. Move by visual line
-- instead, but keep counts (5j) working on real lines for relative jumps.
vim.keymap.set({ "n", "v" }, "j", function() return vim.v.count > 0 and "j" or "gj" end,
    { buffer = true, expr = true, desc = "Down (visual line)" })
vim.keymap.set({ "n", "v" }, "k", function() return vim.v.count > 0 and "k" or "gk" end,
    { buffer = true, expr = true, desc = "Up (visual line)" })

-- Second <CR> on a bare `> ` line clears it, so you leave a callout the same
-- way you leave a list: press enter twice.
vim.keymap.set("i", "<CR>", function()
    if vim.api.nvim_get_current_line():match("^%s*>[%s>]*$") then
        return "<C-g>u<C-u>" -- undo point, then wipe the dangling marker
    end
    return "<CR>"
end, { buffer = true, expr = true, desc = "Newline, or exit an empty callout/quote" })

-- Toggle Line Numbers (Visual Selection)
function ToggleNumberVisualSelection()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)

    -- Check if any line for numbering
    local has_numbers = false
    for i = 1, #lines do
        if lines[i]:match("^%s*%d+%.%s") then
            has_numbers = true
            break
        end
    end

    if has_numbers then
        -- remove numbers
        for i = 1, #lines do
            lines[i] = lines[i]:gsub("^%s*%d+%.%s*", "")
        end
        print("✓ Numbers removed")
    else
        -- add numbers
        for i = 1, #lines do
            lines[i] = i .. ". " .. lines[i]
        end
        print("✓ Numbers added")
    end

    vim.fn.setline(start_line, lines)
end

-- Toggle Line Numbers for Current Line (Normal Mode)
function ToggleNumberCurrentLine()
    local line_num = vim.fn.line(".")
    local line = vim.fn.getline(line_num)

    if line:match("^%s*%d+%.%s") then
        -- Remove number
        line = line:gsub("^%s*%d+%.%s*", "")
        print("✓ Number removed")
    else
        -- Add number
        line = "1. " .. line
        print("✓ Number added")
    end

    vim.fn.setline(line_num, line)
end

-- Toggle Bullet Points for (Visual Selection)
function ToggleBulletVisualSelection()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)

    -- Check if any line has bullets
    local has_bullets = false
    for i = 1, #lines do
        if lines[i]:match("^%s*[%-%*%+]%s") then
            has_bullets = true
            break
        end
    end

    if has_bullets then
        -- Remove bullets
        for i = 1, #lines do
            lines[i] = lines[i]:gsub("^(%s*)[%-%*%+]%s*", "%1")
        end
        print("✓ Bullets removed")
    else
        -- Add bullets
        for i = 1, #lines do
            -- Only add bullet if line isn't already a bullet or checkbox
            if not lines[i]:match("^%s*[%-%*%+]%s") and not lines[i]:match("^%s*%d+%.%s") then
                lines[i] = "- " .. lines[i]
            end
        end
        print("✓ Bullets added")
    end

    vim.fn.setline(start_line, lines)
end

-- Toggle Bullet Points for Current Line (Normal Mode)
function ToggleBulletCurrentLine()
    local line_num = vim.fn.line(".")
    local line = vim.fn.getline(line_num)

    if line:match("^%s*[%-%*%+]%s") then
        -- Remove bullet
        line = line:gsub("^(%s*)[%-%*%+]%s*", "%1")
        print("✓ Bullet removed")
    else
        -- Add bullet
        if not line:match("^%s*%d+%.%s") then
            line = "- " .. line
            print("✓ Bullet added")
        end
    end

    vim.fn.setline(line_num, line)
end

-- Toggle Checkboxes for (Visual Selection)
function ToggleCheckboxVisualSelection()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)

    -- Check if any line has checkboxes
    local has_checkboxes = false
    for i = 1, #lines do
        if lines[i]:match("^%s*%-%s*%[.%]%s") then
            has_checkboxes = true
            break
        end
    end

    if has_checkboxes then
        -- Remove checkboxes (convert back to bullets)
        for i = 1, #lines do
            lines[i] = lines[i]:gsub("^(%s*%-)%s*%[.%]%s*", "%1 ")
        end
        print("✓ Checkboxes removed")
    else
        -- Add checkboxes
        for i = 1, #lines do
            if lines[i]:match("^%s*%-%s") then
                -- Convert existing bullet to checkbox
                lines[i] = lines[i]:gsub("^(%s*%-)%s*", "%1 [ ] ")
            elseif not lines[i]:match("^%s*$") then
                -- Add checkbox with bullet to non-empty lines
                lines[i] = "- [ ] " .. lines[i]
            end
        end
        print("✓ Checkboxes added")
    end

    vim.fn.setline(start_line, lines)
end

-- Toggle Checkboxes for Current Line (Normal Mode)
function ToggleCheckboxCurrentLine()
    local line_num = vim.fn.line(".")
    local line = vim.fn.getline(line_num)

    if line:match("^%s*%-%s*%[.%]%s") then
        -- Remove checkbox (convert back to bullet)
        line = line:gsub("^(%s*%-)%s*%[.%]%s*", "%1 ")
        print("✓ Checkbox removed")
    else
        -- Add checkbox
        if line:match("^%s*%-%s") then
            -- Convert existing bullet to checkbox
            line = line:gsub("^(%s*%-)%s*", "%1 [ ] ")
        elseif not line:match("^%s*$") then
            -- Add checkbox with bullet to non-empty line
            line = "- [ ] " .. line
        end
        print("✓ Checkbox added")
    end

    vim.fn.setline(line_num, line)
end

-- Toggle Task State for (Visual Selection)
function ToggleTaskStateVisualSelection()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)
    local changed = 0

    for i = 1, #lines do
        if lines[i]:match("^%s*%-%s*%[ %]") then
            -- Mark as done
            lines[i] = lines[i]:gsub("(%[) (])", "%1x%2")
            changed = changed + 1
        elseif lines[i]:match("^%s*%-%s*%[x%]") or lines[i]:match("^%s*%-%s*%[X%]") then
            -- Mark as undone
            lines[i] = lines[i]:gsub("(%[)[xX](])", "%1 %2")
            changed = changed + 1
        end
    end

    if changed > 0 then
        vim.fn.setline(start_line, lines)
        print("✓ " .. changed .. " tasks toggled")
    else
        print("○ No checkboxes found to toggle")
    end
end

-- Toggle Task State for Current Line (Normal Mode)
function ToggleTaskStateCurrentLine()
    local line_num = vim.fn.line(".")
    local line = vim.fn.getline(line_num)

    if line:match("^%s*%-%s*%[ %]") then
        -- Mark as done
        line = line:gsub("(%[) (])", "%1x%2")
        print("✓ Task completed")
    elseif line:match("^%s*%-%s*%[x%]") or line:match("^%s*%-%s*%[X%]") then
        -- Mark as undone
        line = line:gsub("(%[)[xX](])", "%1 %2")
        print("○ Task reopened")
    else
        print("○ No checkbox found to toggle")
    end

    vim.fn.setline(line_num, line)
end

-- Smart List Toggle for (Visual Selection)
function SmartListToggleVisualSelection()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)

    -- Determine current state
    local has_numbers = false
    local has_checkboxes = false
    local has_bullets = false

    for i = 1, #lines do
        if lines[i]:match("^%s*%d+%.%s") then
            has_numbers = true
        elseif lines[i]:match("^%s*%-%s*%[.%]%s") then
            has_checkboxes = true
        elseif lines[i]:match("^%s*[%-%*%+]%s") then
            has_bullets = true
        end
    end

    if has_numbers then
        -- Remove all formatting
        for i = 1, #lines do
            lines[i] = lines[i]:gsub("^%s*%d+%.%s*", "")
        end
        print("✓ All formatting removed")
    elseif has_checkboxes then
        -- Convert to numbers
        for i = 1, #lines do
            lines[i] = lines[i]:gsub("^(%s*)%-%s*%[.%]%s*", "%1")
            if not lines[i]:match("^%s*$") then
                lines[i] = i .. ". " .. lines[i]
            end
        end
        print("✓ Converted to numbered list")
    elseif has_bullets then
        -- Convert to checkboxes
        for i = 1, #lines do
            lines[i] = lines[i]:gsub("^(%s*)[%-%*%+]%s*", "%1- [ ] ")
        end
        print("✓ Converted to checkboxes")
    else
        -- Add bullets
        for i = 1, #lines do
            if not lines[i]:match("^%s*$") then
                lines[i] = "- " .. lines[i]
            end
        end
        print("✓ Added bullets")
    end

    vim.fn.setline(start_line, lines)
end

-- Smart List Toggle for Current Line (Normal Mode)
function SmartListToggleCurrentLine()
    local line_num = vim.fn.line(".")
    local line = vim.fn.getline(line_num)

    if line:match("^%s*%d+%.%s") then
        -- Remove all formatting
        line = line:gsub("^%s*%d+%.%s*", "")
        print("✓ All formatting removed")
    elseif line:match("^%s*%-%s*%[.%]%s") then
        -- Convert to number
        line = line:gsub("^(%s*)%-%s*%[.%]%s*", "%1")
        if not line:match("^%s*$") then
            line = "1. " .. line
        end
        print("✓ Converted to numbered list")
    elseif line:match("^%s*[%-%*%+]%s") then
        -- Convert to checkbox
        line = line:gsub("^(%s*)[%-%*%+]%s*", "%1- [ ] ")
        print("✓ Converted to checkbox")
    else
        -- Add bullet
        if not line:match("^%s*$") then
            line = "- " .. line
            print("✓ Added bullet")
        end
    end

    vim.fn.setline(line_num, line)
end

-- Setting commands (buffer-local: this file re-runs for every markdown buffer,
-- and these are only useful in markdown anyway)
local cmd = function(name, fn) vim.api.nvim_buf_create_user_command(0, name, fn, {}) end
cmd("ToggleNumberVisual", ToggleNumberVisualSelection)
cmd("ToggleBulletVisual", ToggleBulletVisualSelection)
cmd("ToggleCheckboxVisual", ToggleCheckboxVisualSelection)
cmd("ToggleTaskStateVisual", ToggleTaskStateVisualSelection)
cmd("SmartListToggleVisual", SmartListToggleVisualSelection)

-- Keymaps for Bullet, Checkbox, Number list.
-- These live under <leader>m rather than bare `t*`: `t` is the till-motion, and
-- mapping tn/tb/tc/tt/tl on top of it broke `tx` jumps and made every `t` wait
-- for timeoutlen.
local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
    wk.add({ { "<leader>m", group = "markdown", icon = " ", buffer = 0 } })
end

local function md(lhs, normal_fn, visual_cmd, desc)
    vim.keymap.set("n", "<leader>m" .. lhs, normal_fn, { buffer = true, desc = desc .. " (line)" })
    vim.keymap.set("v", "<leader>m" .. lhs, ":<C-u>" .. visual_cmd .. "<CR>",
        { buffer = true, desc = desc .. " (selection)" })
end

md("n", ToggleNumberCurrentLine, "ToggleNumberVisual", "Toggle numbering")
md("b", ToggleBulletCurrentLine, "ToggleBulletVisual", "Toggle bullets")
md("c", ToggleCheckboxCurrentLine, "ToggleCheckboxVisual", "Toggle checkboxes")
md("t", ToggleTaskStateCurrentLine, "ToggleTaskStateVisual", "Toggle task done")
md("l", SmartListToggleCurrentLine, "SmartListToggleVisual", "Smart list cycle")

-- ── Callouts ────────────────────────────────────────────────────────────────
-- Insert a callout block, or wrap the visual selection in one. Types mirror
-- lua/bigb/plugins/render-markdown.lua so what you insert is what renders.
local CALLOUTS = {
    { "NOTE",       "󰋽" },
    { "TIP",        "󰌶" },
    { "IDEA",       "󰛨" },
    { "IMPORTANT",  "󰅾" },
    { "QUESTION",   "󰘥" },
    { "SUMMARY",    "󰨸" },
    { "EXAMPLE",    "󰉹" },
    { "QUOTE",      "󱆨" },
    { "DEFINITION", "󰗚" },
    { "INSIGHT",    "󰧑" },
    { "SOURCE",     "󰈙" },
    { "GOAL",       "󰄴" },
    { "TODO",       "󰗡" },
    { "WARNING",    "󰀪" },
    { "DANGER",     "󱐌" },
}

--- Prompt for a callout type, then hand the chosen name to `apply`.
---@param apply fun(kind: string)
local function pick_callout(apply)
    vim.ui.select(CALLOUTS, {
        prompt = "Callout type",
        format_item = function(item) return item[2] .. "  " .. item[1] end,
    }, function(choice)
        if choice then apply(choice[1]) end
    end)
end

local function insert_callout()
    pick_callout(function(kind)
        local row = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, row, row, false, { "> [!" .. kind .. "]", "> " })
        vim.api.nvim_win_set_cursor(0, { row + 2, 2 })
        vim.cmd("startinsert!")
    end)
end

local function wrap_callout()
    -- leave visual mode first so the '< '> marks are set
    vim.cmd("normal! \27")
    local first, last = vim.fn.line("'<"), vim.fn.line("'>")
    pick_callout(function(kind)
        local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
        for i, line in ipairs(lines) do
            lines[i] = line == "" and ">" or ("> " .. line)
        end
        table.insert(lines, 1, "> [!" .. kind .. "]")
        vim.api.nvim_buf_set_lines(0, first - 1, last, false, lines)
    end)
end

vim.keymap.set("n", "<leader>mC", insert_callout, { buffer = true, desc = "Insert callout" })
vim.keymap.set("v", "<leader>mC", wrap_callout, { buffer = true, desc = "Wrap selection in callout" })

-- Task management keymaps (buffer-local)
local opts = { buffer = 0, silent = true }

-- Status message
local function safe_markdown_cmd(cmd, success_msg)
    return function()
        -- remember where we were so the cursor survives the :g command
        vim.cmd("normal! m'")

        -- run
        local ok, err = pcall(vim.cmd, cmd)

        if ok then
            print("✓ " .. success_msg)
        else
            print("✗ Failed: " .. err)
            -- Undo the change if it failed
            vim.cmd("undo")
        end
    end
end

-- moved off <leader>t* so it stops colliding with the global tab group
vim.keymap.set("n", "<leader>mx",
    safe_markdown_cmd("g/- \\[ \\]/s/\\[ \\]/[x]/", "Marked all tasks as done"),
    vim.tbl_extend("force", opts, { desc = "Mark all tasks done" }))

vim.keymap.set("n", "<leader>mu",
    safe_markdown_cmd("g/- \\[x\\]/s/\\[x\\]/[ ]/", "Marked all tasks as undone"),
    vim.tbl_extend("force", opts, { desc = "Mark all tasks undone" }))

-- Toggle headings
local function toggle_heading(level)
    local line = vim.api.nvim_get_current_line()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- Remove existing heading
    local content = line:gsub("^#+%s*", "")

    -- Check if line already has this heading level
    local current_level = line:match("^(#+)")
    if current_level and #current_level == level then
        -- Remove heading (toggle off)
        vim.api.nvim_set_current_line(content)
        -- Had to readjust cursor position
        vim.api.nvim_win_set_cursor(0, { cursor_pos[1], math.max(0, cursor_pos[2] - level - 1) })
    else
        -- Add or change heading level
        local new_line = string.rep("#", level) .. " " .. content
        vim.api.nvim_set_current_line(new_line)
        -- Adjust cursor position
        vim.api.nvim_win_set_cursor(0, { cursor_pos[1], cursor_pos[2] + level + 1 })
    end
end

-- Heading keymaps 1-6 (moved off <leader>h*, which is the harpoon group)
for level = 1, 6 do
    vim.keymap.set("n", "<leader>m" .. level, function() toggle_heading(level) end,
        { buffer = true, desc = "Toggle H" .. level })
end

-- ** Header Colors **
-- Moved to lua/bigb/plugins/render-markdown.lua so the palette lives in one
-- place, is applied once instead of per buffer, and survives a colorscheme
-- change (a `:colorscheme` wipes user highlights).
