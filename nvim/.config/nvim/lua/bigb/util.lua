-- Small shared values/helpers. Not a plugin spec -- it lives outside
-- lua/bigb/plugins/ so lazy.nvim's `import` never picks it up.

local M = {}

--- Obsidian vault root. Also used by lua/bigb/plugins/obsidian.lua.
--- Same path on every machine, so no per-OS detection is needed -- `~` expands
--- correctly on both Linux and macOS.
M.vault = vim.fn.expand("~/Documents/BigB-PKM")

--- Files that mark the top of a project.
M.root_markers = { ".git", "lazy-lock.json", "package.json", "Cargo.toml", "go.mod" }

--- Directory a picker should be anchored to.
--- fff indexes exactly one directory, so opening it from a nested file would
--- otherwise only search that subtree. Falls back to cwd outside a project.
---@return string
function M.project_root()
    return vim.fs.root(0, M.root_markers) or assert(vim.uv.cwd())
end

--- Compile spell/en.utf-8.add into the .add.spl that Neovim actually reads.
--- The .spl is a build artifact and is kept out of git, but Neovim only rebuilds
--- it on `zg`/`zw` -- never at startup. Without this, a fresh clone would
--- silently ignore the entire scripture dictionary until a word was added by
--- hand. Runs at most once per session, and only when the source is newer.
local spell_compiled = false
function M.ensure_spellfile()
    if spell_compiled then return end
    spell_compiled = true

    local add = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
    local src = vim.uv.fs_stat(add)
    if not src then return end

    local spl = vim.uv.fs_stat(add .. ".spl")
    if spl and spl.mtime.sec >= src.mtime.sec then return end

    pcall(vim.cmd, "silent! mkspell! " .. vim.fn.fnameescape(add))
end

return M
