local map = vim.keymap.set -- local alias, saves typing

-- ============================================================================
-- Groups (see lua/bigb/plugins/which-key.lua for the popup labels)
--   <leader>b  buffer      <leader>c  code       <leader>e  explorer
--   <leader>f  file/find   <leader>h  harpoon    <leader>m  markdown (md only)
--   <leader>o  obsidian    <leader>s  search     <leader>t  tab
--   <leader>u  ui toggle   <leader>w  window     <leader>x  diagnostics
-- Plugin-owned keys live next to their plugin spec, not here.
-- ============================================================================

-- ── Editing basics ──────────────────────────────────────────────────────────
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("n", "<ESC>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv", { desc = "Outdent, keep selection" })
map("v", ">", ">gv", { desc = "Indent, keep selection" })

map("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })
map("n", "n", "nzzzv", { desc = "Next match, centered" })
map("n", "N", "Nzzzv", { desc = "Prev match, centered" })

-- keep the unnamed register clean
map("x", "p", [["_dP]], { desc = "Paste over selection (keep yank)" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to black hole" })
map("n", "x", '"_x', { desc = "Delete char to black hole" })

-- ── Top level ───────────────────────────────────────────────────────────────
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR><ESC>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa<CR>", { desc = "Quit all" })
map("n", "<leader>R", "<cmd>restart<CR>", { desc = "Restart Neovim" })
map("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Lazy (plugin manager)" })
map("n", "<leader>M", "<cmd>Mason<CR>", { desc = "Mason (LSP installer)" })

-- ── Window navigation (non-leader, used constantly) ─────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- ── <leader>w  Window ───────────────────────────────────────────────────────
map("n", "<leader>wv", "<C-w>v", { desc = "Split vertically" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split horizontally" })
map("n", "<leader>we", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>wd", "<cmd>close<CR>", { desc = "Close window" })
map("n", "<leader>wo", "<cmd>only<CR>", { desc = "Close other windows" })

-- ── <leader>t  Tab ──────────────────────────────────────────────────────────
map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "This file in new tab" })

-- ── <leader>b  Buffer ───────────────────────────────────────────────────────
--- Delete a buffer without collapsing the window it lives in.
---@param force boolean
local function buf_delete(force)
    local cur = vim.api.nvim_get_current_buf()
    local alt = vim.fn.bufnr("#")
    if alt ~= -1 and alt ~= cur and vim.api.nvim_buf_is_valid(alt) then
        vim.api.nvim_set_current_buf(alt)
    else
        vim.cmd("enew")
    end
    local ok, err = pcall(vim.api.nvim_buf_delete, cur, { force = force })
    if not ok then
        vim.api.nvim_set_current_buf(cur)
        vim.notify(err, vim.log.levels.WARN)
    end
end

--- Delete every listed buffer, optionally keeping the current one.
---@param keep_current boolean
local function buf_delete_many(keep_current)
    local cur = vim.api.nvim_get_current_buf()
    local closed, skipped = 0, 0
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local keep = keep_current and buf == cur
        if vim.bo[buf].buflisted and not keep then
            if vim.bo[buf].modified then
                skipped = skipped + 1
            elseif pcall(vim.api.nvim_buf_delete, buf, {}) then
                closed = closed + 1
            end
        end
    end
    local msg = ("Closed %d buffer(s)"):format(closed)
    if skipped > 0 then
        msg = msg .. (", skipped %d unsaved"):format(skipped)
    end
    vim.notify(msg, vim.log.levels.INFO)
end

map("n", "<leader>bb", "<cmd>buffer #<CR>", { desc = "Switch to last buffer" })
map("n", "<leader>bd", function() buf_delete(false) end, { desc = "Delete buffer" })
map("n", "<leader>bD", function() buf_delete(true) end, { desc = "Delete buffer (force)" })
map("n", "<leader>bo", function() buf_delete_many(true) end, { desc = "Close other buffers" })
map("n", "<leader>ba", function() buf_delete_many(false) end, { desc = "Close all buffers" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- ── <leader>f  File ─────────────────────────────────────────────────────────
-- (ff / fr / fg / fc are picker-owned, see fff.lua and telescope.lua)
map("n", "<leader>fs", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>fS", "<cmd>wall<CR>", { desc = "Save all files" })
map("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New file" })
map("n", "<leader>fp", function()
    local path = vim.fn.expand("%:~")
    vim.fn.setreg("+", path)
    vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy file path" })

-- ── <leader>u  UI toggles ───────────────────────────────────────────────────
--- Flip a boolean window/buffer option and report the new state.
---@param opt string
---@param label string
local function toggle_opt(opt, label)
    return function()
        local value = not vim.opt_local[opt]:get()
        vim.opt_local[opt] = value
        vim.notify(("%s %s"):format(label, value and "on" or "off"), vim.log.levels.INFO)
    end
end

map("n", "<leader>uw", toggle_opt("wrap", "Wrap"), { desc = "Toggle wrap" })
map("n", "<leader>us", toggle_opt("spell", "Spell"), { desc = "Toggle spell check" })
map("n", "<leader>un", toggle_opt("number", "Line numbers"), { desc = "Toggle line numbers" })
map("n", "<leader>ur", toggle_opt("relativenumber", "Relative numbers"), { desc = "Toggle relative numbers" })
map("n", "<leader>uh", "<cmd>set hlsearch!<CR>", { desc = "Toggle search highlight" })
map("n", "<leader>ud", function()
    local enabled = not vim.diagnostic.is_enabled()
    vim.diagnostic.enable(enabled)
    vim.notify("Diagnostics " .. (enabled and "on" or "off"), vim.log.levels.INFO)
end, { desc = "Toggle diagnostics" })

-- ── <leader>x  Diagnostics / lists ──────────────────────────────────────────
map("n", "<leader>xq", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
