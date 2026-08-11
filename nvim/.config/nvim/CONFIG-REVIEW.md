# Neovim Config Review — `learnvim`

**Reviewed:** 2026-08-11
**Config:** `~/.config/learnvim` (launched via `NVIM_APPNAME=learnvim`)
**Neovim:** v0.12.4 · **Plugins:** 29 locked · **Startup:** ~100–127 ms

Evaluated against your stated uses: **AI Engineering studies**, **Vachanamrut & Swamini Vato
studies**, **Satsang Diksha Adhyayan**, **general note taking**, and **learning Python, SQL,
and Bash**.

---

## Overall Score: **7.5 / 10**

This is a well-built, deliberately-reasoned config — clearly above a copied-together setup.
The comments explain *why* rather than *what*, conflicts were diagnosed and resolved rather
than worked around, and the Neovim APIs used are current (0.11+ `vim.lsp.config`, treesitter
`main` branch). The **note-taking and markdown layer is genuinely excellent**.

The score is held back by a consistent pattern: **the config is strong where you have already
done work, and absent where you have not started yet.** Markdown/Obsidian is a 9. SQL and Bash
— two of the three languages you say you're learning — have syntax highlighting and nothing
else. And your scripture study has a typography problem that has probably been quietly
degrading your notes without an obvious cause.

### Scorecard

| Domain | Score | One-line verdict |
|---|:---:|---|
| General note taking | **9.0** | Exceptional. Callouts, soft-wrap prose, visual-line motion, Obsidian parity. |
| Markdown authoring | **9.0** | Insert-side and render-side callouts kept in sync. Rare to see. |
| Config craftsmanship | **8.5** | Comments justify decisions; conflicts resolved on purpose. |
| Python | **8.0** | basedpyright + ruff + conform is a proper toolchain. |
| Performance | **7.0** | 20 of 29 plugins load eagerly; ~113 ms average. |
| AI Engineering | **6.5** | Good editor, no ML workflow: no notebooks, REPL, venv, or API client. |
| Scripture studies | **6.0** | Great note substrate, but script/diacritic rendering is broken (see §1). |
| Bash | **3.5** | Treesitter grammar only. No LSP, lint, format, or terminal. |
| SQL | *n/a* | Out of scope — PostgreSQL is worked in pgAdmin, not Neovim. |

---

## What Is Genuinely Very Good

These are worth naming because they are not accidents.

**The markdown prose model.** `after/ftplugin/markdown.lua` keeps a paragraph as one physical
line and soft-wraps it, so a callout can never lose its `> ` prefix mid-thought and the file
round-trips to the Obsidian app cleanly. Then `j`/`k` are remapped to `gj`/`gk` **but only when
no count is given**, so `5j` still jumps 5 real lines. That is a subtle, correct detail most
configs get wrong.

**The callout system is coherent end to end.** The 15 types in the ftplugin's `CALLOUTS` table
mirror `render-markdown.lua`'s `callout` table, and the comment notes the accent colour is kept
in sync with `.obsidian/snippets/nvim-callouts.css`. Insert → render → Obsidian app all agree.
For scripture study — where `[!QUOTE]`, `[!DEFINITION]`, `[!INSIGHT]`, `[!SOURCE]` map naturally
onto verse / term / reflection / citation — this is the single most valuable thing in the config.

**Obsidian config mirrors the actual vault.** `notes_subdir`, `daily_notes.folder`,
`attachments.folder`, and `link.style` are each commented as mirroring a specific
`.obsidian/*.json` key, and `frontmatter.enabled = false` is disabled *with a stated reason*
(your Dataview schema would get rewritten). Someone read the vault before writing the config.

**The Templater shim.** obsidian.nvim doesn't expand `<% tp.date.now(...) %>`, so you wrote an
`ObsidianNoteEnter` autocmd that expands it and skips template files themselves. Practical.

**Conflict resolution is documented, not guessed.** `mini.surround`'s `replace` moved off `ca`
because it shadowed the `ca` text object; markdown toggles moved off `t*` because it broke the
till-motion; harpoon uses `<M-n>` because `<C-i>` is `<Tab>` in a terminal and would break the
jumplist. Three real bugs, each diagnosed and explained.

**Modern APIs.** `vim.lsp.config()` / `vim.lsp.enable()` rather than legacy `lspconfig.setup()`,
treesitter on `main` with `require("nvim-treesitter").install()`. This config will not rot in
six months.

---

## Verified Findings

Everything below was checked against your actual system, not inferred.

### 1. 🟢 CORRECTED — font fallback already works; no action needed

> **This finding was wrong in the first version of this review and has been retracted.**
> The original conclusion ("diacritics fall back to proportional Liberation Sans, causing
> column drift") came from `fc-match ":charset=1E5B"` — a **family-less** query, which is not
> how a terminal resolves a missing glyph. A terminal asks for its configured family and walks
> that family's fallback chain. Tracing the real chain for `JetBrainsMono Nerd Font`:
>
> | Script | First font in chain with coverage | Chain position | Monospace? |
> |---|---|:---:|:---:|
> | IAST (`ṛ ṣ ṇ ṭ ḍ ṃ ḥ`) | **Noto Sans Mono** | 2 | ✅ yes |
> | Gujarati | Noto Sans Gujarati | 24 | ✗ (no mono Indic exists) |
> | Devanagari | Noto Sans Devanagari | 40 | ✗ (same) |
>
> Fontconfig walks the chain until it finds coverage, so **all three scripts already render
> correctly today**, and IAST resolves to a monospace font — there is no column drift. The
> proposed `~/.config/fontconfig/conf.d/` file was **not created**; it would have been
> redundant configuration.
>
> What remains true: JetBrainsMono Nerd Font itself genuinely lacks these glyphs (13/24 IAST
> characters, 1/128 Gujarati, 0/128 Devanagari). That is fine — it is what fallback is for.
> Retained below as reference for *why* the fallback matters, and in case you ever switch to
> a font whose fallback chain is worse.

<details>
<summary>Original finding (retracted — kept for reference)</summary>

#### Your font cannot render Sanskrit transliteration

`JetBrainsMono Nerd Font` is the primary font in ghostty, kitty, and foot. Checking its charset
directly against the diacritics used in IAST/ISO-15919 transliteration:

```
tested : ā Ā ī Ī ū Ū ṛ Ṛ ṝ ḷ ṅ ñ ṭ ḍ ṇ ś Ś ṣ Ṣ ṃ ṁ ḥ ĕ ŏ
MISSING: ṛ Ṛ ṝ ḷ ṅ ṭ ḍ ṇ ṣ Ṣ ṃ ṁ ḥ          ← 13 of 24
```

Those are not obscure. They are the characters in:

> K**ṛṣ**ṇa · Ak**ṣ**ar · Puru**ṣ**ottam · Vacanām**ṛ**t · Sa**ṃ**sk**ṛ**t · Śrī Svāminārāya**ṇ** · Sa**ṃ**hitā

Every one falls back to **Liberation Sans** — a *proportional* font. In a monospace grid that
means inconsistent glyph widths, so cursor position and column alignment drift on any line
containing a transliterated term. Tables and aligned text will not line up.

Native script coverage is worse:

| Script | Coverage in JetBrainsMono NF | Fallback available |
|---|---|---|
| Gujarati (U+0A80–0AFF) | **1 / 128** | Noto Sans Gujarati ✅ installed |
| Devanagari (U+0900–097F) | **0 / 128** | Noto Sans Devanagari ✅ installed |

The good news: **Noto Sans Mono is already installed and covers 8/8 of the missing IAST
characters** — and it is monospace. This is a fontconfig fix, not a font purchase.

```xml
<!-- ~/.config/fontconfig/conf.d/50-iast-fallback.conf -->
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias>
    <family>JetBrainsMono Nerd Font</family>
    <prefer>
      <family>Noto Sans Mono</family>        <!-- IAST diacritics, monospace -->
      <family>Noto Sans Gujarati</family>
      <family>Noto Sans Devanagari</family>
    </prefer>
  </alias>
</fontconfig>
```

Then `fc-cache -f` and restart the terminal. Verify with:
`echo "Kṛṣṇa Akṣar Puruṣottam · ગુજરાતી · श्री"`

> Note: Gujarati and Devanagari have no true monospace design, so those will still be
> proportional. That is unavoidable and normal — but they will at least *render*.

</details>

### 2. ✅ APPLIED — Spell check flags every scripture term

`after/ftplugin/markdown.lua:9` sets `spell = true` with default `spelllang=en`. Every instance
of *Vachanamrut, Swamini, Satsang Diksha, Adhyayan, Akshar, Purushottam, Maharaj, Swami, shloka,
Gunatitanand, Bhagwan* gets a red underline. With hundreds of these per note the spell layer
becomes noise and you stop seeing real typos.

**Applied.** `after/ftplugin/markdown.lua` now sets `spellfile` to
`~/.config/learnvim/spell/en.utf-8.add` and appends `camel` to `spelloptions`. The dictionary
was created and pre-seeded with ~150 terms (scripture names, Vachanamrut place-sections, gurus,
theological vocabulary) and compiled to `.add.spl`.

Verified: all of *Vachanamrut, Swamishri, Aksharbrahman, Purushottam, shloka, ekantik, upasana,
nishtha, mahima, gnan* now pass, while genuine typos (`teh`, `recieve`) are still flagged.

`zg` on any new word appends it permanently; `zw` marks a word wrong; `z=` suggests corrections.

### 3. ✅ APPLIED — Case-sensitive search — was `ignorecase=false smartcase=false`

Not set anywhere in `core/options.lua`. Searching your vault for `vachanamrut` will not find
`Vachanamrut`. For a config whose primary use is reading and searching prose, this is the single
highest-value two-line change:

**Applied** in `core/options.lua`. Verified behaviourally, not just by option value:
`/swamishri` now finds `Swamishri`, while `/SWAMISHRI` correctly finds nothing — smartcase
re-arms case sensitivity the moment the query contains a capital.

### 4. ✅ APPLIED — The theme switcher silently cannot persist

`telescope.lua:32` sets the themes-extension persist path to:

```
~/.config/learnvim/lua/colorscheme.lua
```

That file **does not exist and is never `require`d** — your actual colorscheme lives at
`lua/bigb/plugins/colorscheme.lua`. So `<leader>ut` changes the theme for the session and it
resets on restart, with no error to explain why.

**Applied — made to work rather than disabled.** Reading the extension source showed it writes
a single line, `vim.cmd("colorscheme <name>")`, to the persist path. So the path now points at
`lua/bigb/current-theme.lua`, and `colorscheme.lua` `dofile()`s it after setting aether.

Verified: with a persisted file present, startup lands on that theme; with it absent, startup
falls back to aether cleanly.

Related: only **one** colorscheme (aether) is installed, so the theme picker has almost nothing
to pick from.

### 5. ✅ APPLIED — conform is configured for formatters that aren't installed

`formatting.lua` declares `stylua` (lua) and `prettierd` (js/ts). Mason has installed only:

```
basedpyright  basedpyright-langserver  lua-language-server  ruff  typescript-language-server
```

Neither `stylua` nor `prettierd` exists on `PATH` or in Mason. Because `format_on_save` uses
`lsp_format = "fallback"`, saving a Lua file quietly uses lua_ls formatting instead — so it
*looks* fine while not doing what the config says.

**Applied.** `mason-tool-installer` added to `lsp/mason.lua` with a declarative tool list —
`stylua`, `prettierd`, `shfmt`, `shellcheck`. mason-lspconfig only handles *servers*, which is why
these were never installed. All four now present in `mason/bin`. (`sqlfluff` was installed here
too, then removed along with the rest of the SQL layer — see §6.)

Verified by actually formatting: stylua → `local x = { a = 1, b = 2 }`;
prettierd → `const x = { a: 1, b: 2 };`; shfmt → 2-space reindent.

### 6. ✅ APPLIED — SQL and Bash have no tooling at all

You listed both as languages you're learning. Current state:

| | Treesitter | LSP | Lint | Format | Run it |
|---|:---:|:---:|:---:|:---:|:---:|
| Python | ✅ | ✅ basedpyright | ✅ ruff | ✅ ruff | ❌ |
| SQL | ✅ | ❌ | ❌ | ❌ | ❌ |
| Bash | ✅ | ❌ | ❌ | ❌ | ❌ |

You get colours and nothing else. No completion, no diagnostics, no "why is this broken."
`shellcheck` in particular is the single best Bash *teacher* available — it explains quoting and
word-splitting mistakes as you make them, which is exactly what a learner needs. Neither
`shellcheck` nor `shfmt` nor `sqlfluff` is installed.

There is also no `after/ftplugin/sh.lua` or `sql.lua`, so both inherit the global 4-space indent
(conventional Bash is 2).

**Applied for Bash. SQL intentionally left out of scope** — see the note below.

| | Treesitter | LSP | Lint | Format | Run it |
|---|:---:|:---:|:---:|:---:|:---:|
| Python | ✅ | ✅ basedpyright | ✅ ruff | ✅ ruff | ✅ iron REPL |
| SQL | ✅ highlighting only | — | — | — | pgAdmin (outside Neovim) |
| Bash | ✅ | ✅ bashls | ✅ shellcheck | ✅ shfmt | — |

> **SQL is deliberately not configured.** PostgreSQL work happens in the pgAdmin web interface,
> so Neovim needs no SQL tooling. The dadbod stack, `sqlfluff`, `after/ftplugin/sql.lua`, and the
> `<leader>D` group were all added and then **removed** at the user's direction; the Mason package
> and the three plugins were uninstalled, not just unwired.
>
> What remains is the treesitter `sql` grammar, kept on purpose: it costs nothing at runtime and
> means a `.sql` file opened for reading still gets syntax highlighting. Say the word if you want
> that dropped from `treesitter.lua` too.
>
> If SQL ever moves into Neovim, the notes below are the starting point — but be aware `sqlls`
> is broken on Node 26 (`ERR_PACKAGE_PATH_NOT_EXPORTED`) and `sqls` is unmaintained.

- **Bash** — `bashls` installed and enabled; it shells out to `shellcheck` off PATH. Verified on
  a deliberately broken script: both unquoted `$foo` expansions were flagged with
  *"Double quote to prevent globbing and word splitting"*. This is the teaching tool the review
  argued for, and it works.
- **`after/ftplugin/sh.lua`** created — 2-space indent. conform passes the buffer's `shiftwidth`
  to shfmt as `-i`, so formatting matches the editor.

### 7. 🟡 PARTLY APPLIED — No notebook, REPL, or API client for AI Engineering

The Python *editing* toolchain is solid. The Python *ML workflow* is entirely absent:

- **No `.ipynb` support** — opening a notebook shows raw JSON. Most AI engineering coursework
  is notebook-delivered.
- **No REPL** — no way to send a visual selection to a live Python session, which is the core
  loop of exploratory data/model work.
- **No venv selection** — basedpyright resolves against whatever interpreter it finds. With
  per-project venvs (mise is on this system) imports will report as unresolved.
- **No image rendering** — matplotlib output cannot be viewed in-editor.
- **No HTTP client** — for LLM API work you leave Neovim to test a request.
- **No debugger** (nvim-dap).

**Applied (the two highest-payoff items):**

- **`iron.nvim`** (`plugins/python.lua`, `<leader>r`) — send a motion, selection, line, or whole
  file to a live `python3`. Uses `bracketed_paste_python` so indented blocks (`def`, `for`, `if`)
  don't get mangled into a syntax error on paste. Verified end-to-end: sending
  `print("hello from iron " + str(6*7))` returned `hello from iron 42` from a live interpreter.
- **`venv-selector.nvim`** (`<leader>cv`) — points basedpyright at the project interpreter, which
  is what fixes phantom "unresolved import" errors in per-project venvs.

> Note: the review originally suggested pinning the `regenerate` branch for venv-selector. That
> branch does not exist — the repo has `main`, `regexp`, and `v1`. It is installed from the
> default branch, which is the current version.

**Still outstanding** (deliberately not added — each is a larger commitment):
`jupytext.nvim` / `molten-nvim` + `image.nvim` for notebooks and inline plots, `kulala.nvim` for
`.http` API testing, `nvim-dap` for step debugging.

### 8. 🟡 20 of 29 plugins load at startup

```
EAGER (20): LuaSnip, aether, alpha-nvim, blink.cmp, fff.nvim, friendly-snippets, harpoon,
            lazy.nvim, mason-lspconfig, mason.nvim, mini.files, mini.nvim, nvim-lspconfig,
            nvim-treesitter, nvim-web-devicons, oil.nvim, plenary.nvim, telescope-fzf-native,
            telescope-themes, telescope.nvim
LAZY  (9):  Comment.nvim, conform.nvim, lualine.nvim, mini.pairs, mini.surround,
            mini.trailspace, obsidian.nvim, render-markdown.nvim, which-key.nvim
```

`telescope.nvim` has no lazy trigger, so it loads at startup and drags in `plenary`, `fzf-native`
and `telescope-themes`. `harpoon` also has no trigger and depends on telescope. `mason.nvim` is
explicitly `lazy = false` but is only needed on `:Mason` or LSP attach. ~113 ms is acceptable,
not fast; converting telescope to `cmd = "Telescope"` + `keys` and harpoon to `keys` would cut
the largest chunk.

### 9. 🟡 Smaller items

- **`after/ftplugin/markdown.lua` defines 10 global functions** (`ToggleNumberVisualSelection`,
  `SmartListToggleCurrentLine`, …) in `_G`, re-created for every markdown buffer opened. They
  should be `local` — the buffer-local commands and keymaps already close over them.
- **`mini.trailspace` runs `require()` on every `CursorMoved`** (`editing.lua:68`, `pattern = "*"`).
  Cheap per call, but it fires constantly. Hoist the `require` out of the callback.
- **`<leader>fg` calls `find_in_git_root()`**, which fff marks `@deprecated`. Still works;
  `<leader>ff` already covers git repos via the `.git` root marker.
- **`mini.nvim` is installed wholesale but only 4 modules are used.** `mini.ai` is free and would
  give you `vaf`/`vif` (function textobjects) for Python — currently you have *no* treesitter
  textobjects at all, in either mini.ai or nvim-treesitter-textobjects form.
- **No git integration.** lualine's `branch`/`diff` work via lualine's own built-in git source,
  so the statusline is fine — but there's no hunk navigation, staging, blame, or diff view.
  `lazygit` is installed system-wide and unwired.
- **No session persistence.** Every launch starts cold at the dashboard. Harpoon covers part of
  this, but not window layout or open buffers.
- **No folding for long documents.** `foldmethod = "manual"` globally. A Vachanamrut note with
  20 headings cannot be collapsed to an outline.
- **No autosave.** For note taking, losing a paragraph to a closed terminal is a real risk.

---

## Domain Analysis

### General Note Taking — 9.0

The strongest part of the config, and nothing important is missing. Callouts, checkbox/bullet/
numbering toggles with sensible cycling, heading toggles `<leader>m1`–`m6`, daily notes,
templates, wiki-links, backlinks, tags, table of contents, image paste. The soft-wrap model is
correct and the `<CR>`-on-empty-callout escape is a nice touch.

To reach 10: heading folding, autosave, and `smartcase`.

### Vachanamrut, Swamini Vato & Satsang Diksha Adhyayan — 6.0

The *substrate* is right — an Obsidian vault of linked markdown with typed callouts is arguably
the ideal tool for scripture study, and `[!QUOTE]` / `[!DEFINITION]` / `[!INSIGHT]` / `[!SOURCE]`
map cleanly onto verse, term, reflection, and citation.

But three things stand between it and being good at this specific job:

1. **Rendering (§1).** Transliteration breaks the monospace grid; native script is tofu. This
   likely explains any "my notes look subtly wrong" feeling. Fix this first.
2. **Spell noise (§2).** English-only dictionary against a heavily Sanskrit/Gujarati vocabulary.
3. **Structure at length.** Vachanamrut is 273 discourses; Satsang Diksha is 315 shlokas. These
   are *long, numbered, hierarchical* texts. Without folding you cannot collapse a note to its
   outline, and without a citation convention (e.g. `[[Gadhada I-27]]`, `[[SD-142]]`) you cannot
   cross-reference reliably. The vault's `note_id_func` preserves human-readable titles, which
   is the right foundation — but nothing enforces or autocompletes a reference format.

Worth adding for Adhyayan specifically: **folding by heading** (below), a **`[!SHLOKA]` callout
type** added to both `CALLOUTS` and render-markdown's `callout` table, and a snippet for the
verse/translation/commentary structure you use repeatedly. Memorisation work would benefit from
a spaced-repetition export, but that is genuinely outside Neovim's scope — the vault is the right
place for it.

**Applied** in `after/ftplugin/markdown.lua` — treesitter heading folding, buffer-local so it
does not disturb the global `foldmethod = "manual"`:

```lua
set.foldmethod = "expr"
set.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
set.foldlevel  = 99   -- start open; zM folds all, zR opens all, za toggles one
```

Verified on a test note: `# H1` → foldlevel 1, `## H2` → 2, `### H3` → 3, nesting correctly.

### AI Engineering Studies — 6.5

`basedpyright` (standard type checking) + `ruff` (lint) + `ruff_fix`/`ruff_format`/
`ruff_organize_imports` on save is a legitimately good Python setup — better than most.

The gap is that AI engineering is not primarily *writing Python files*. It is running cells,
inspecting tensors and dataframes, viewing plots, switching between project venvs, and poking at
model APIs. None of that exists here. See §7. Concretely, in rough order of payoff:

| Need | Suggested | Notes |
|---|---|---|
| Send code to a live REPL | `iron.nvim` | Simplest real win; low setup cost |
| `.ipynb` files | `jupytext.nvim` | Edits notebooks as markdown |
| Inline cell output + plots | `molten-nvim` + `image.nvim` | Powerful; setup is involved |
| Per-project venv | `venv-selector.nvim` | Fixes phantom import errors |
| Test LLM APIs in-editor | `kulala.nvim` | `.http` files, pure Lua |
| Step debugging | `nvim-dap` + `nvim-dap-python` | Add once you hit a real bug |

Start with `iron.nvim` and `venv-selector.nvim` — together they cover most day-to-day friction
for a fraction of the setup cost of the Molten stack.

### Python / Bash — was 8.0 / 3.5, now 8.5 / 8.0

Python was already well served. Bash was not served at all beyond colours, and is now the
biggest single improvement in this pass:

```lua
-- lsp/mason.lua
ensure_installed = { "lua_ls", "basedpyright", "ruff", "ts_ls", "bashls" }
-- lspconfig.lua
vim.lsp.enable({ "lua_ls", "basedpyright", "ruff", "ts_ls", "bashls" })
-- formatting.lua
sh = { "shfmt" }, bash = { "shfmt" },
```

`bashls` shells out to `shellcheck` for diagnostics automatically once it is on PATH — that
alone teaches more Bash than a tutorial, because it explains quoting and word-splitting errors
at the moment you make them. Confirmed working on a deliberately broken script.

SQL is not covered here by choice: PostgreSQL work lives in pgAdmin (§6).

**Still outstanding: no terminal integration.** Nothing runs `./script.sh` or `python foo.py`
without leaving the editor. `iron.nvim` now closes this loop for Python and, via its `sh` REPL
definition, partially for Bash — but `toggleterm.nvim` or `:terminal` on a keymap would cover
the general case.

---

## Prioritised Actions

**P0 — ✅ COMPLETE (applied 2026-08-11)**

1. ~~Fontconfig fallback~~ — **retracted, no action needed.** Fallback already resolves all
   three scripts correctly (§1).
2. ✅ `ignorecase` + `smartcase` — `core/options.lua`.
3. ✅ Spellfile + ~150-term seeded dictionary — `after/ftplugin/markdown.lua`, `spell/en.utf-8.add`.
4. ✅ Markdown heading folding — `after/ftplugin/markdown.lua`.

**P1 — ✅ COMPLETE (applied 2026-08-11)**

5. ✅ `bashls` + `shellcheck` + `shfmt` — Bash 3.5 → **8.0**.
6. ⊘ SQL — **out of scope by decision.** PostgreSQL is handled in pgAdmin, so the dadbod stack
   and `sqlfluff` were removed after being installed. Not scored.
7. ✅ `iron.nvim` + `venv-selector.nvim` — AI Engineering 6.5 → **7.5**.
8. ✅ `mason-tool-installer` installs stylua/prettierd/shfmt/shellcheck.
9. ✅ Theme persist path fixed and verified working.

**Revised scores after P0 + P1**

| Domain | Before | After |
|---|:---:|:---:|
| General note taking | 9.0 | **9.5** |
| Scripture studies | 6.0 | **8.5** |
| AI Engineering | 6.5 | **7.5** |
| Python | 8.0 | **8.5** |
| Bash | 3.5 | **8.0** |
| SQL | 3.0 | *n/a — pgAdmin* |
| **Overall** | **7.5** | **8.7** |

SQL is excluded from the overall rather than counted as a gap: a tool you have deliberately
chosen not to put in Neovim is not a deficiency in the config.

Startup is essentially unchanged — 32 plugins (was 29), ~100–132 ms, because every plugin added
is lazy-loaded on `ft`, `cmd`, or `keys`.

**P2 — quality of life**

10. `gitsigns.nvim`, and wire the `lazygit` you already have.
11. `persistence.nvim` for session restore.
12. Enable `mini.ai` — free, already installed.
13. Lazy-load telescope and harpoon (§8).
14. Localise the 10 global functions in the markdown ftplugin (§9).
15. Autosave for vault notes.

---

## Closing

The craftsmanship here is above average and the note-taking layer is genuinely excellent — the
callout system and the prose-wrapping model are things most people never get right. The config's
weakness is not quality but **coverage**: it is a very good markdown-and-Python editor being
asked to also serve SQL, Bash, notebooks, and Sanskrit-script scripture study, none of which it
has been set up for yet.

The four P0 items are roughly fifteen lines of configuration plus one fontconfig file, and they
address the parts of the config that touch your study work every single day. Do those, and the
scripture and note-taking side moves from 6.0 to solidly 8.5+. The P1 items are what turn
"learning SQL and Bash" from reading into practising.

---

<details>
<summary>Verification method</summary>

Claims in this review were checked, not assumed:

- Font coverage — parsed `fc-query --format="%{charset}"` for
  `JetBrainsMonoNerdFont-Regular.ttf` and tested each codepoint individually; fallbacks resolved
  via `fc-match ":charset=<cp>"`.
- Search options — read back from a live headless session (`ignorecase=false smartcase=false`).
- Theme persist path — `vim.uv.fs_stat` on the configured target returned nil.
- Installed formatters/LSPs — `ls ~/.local/share/learnvim/mason/bin/` plus `command -v`.
- Eager vs lazy plugins — enumerated `require("lazy.core.config").plugins[*]._.loaded`.
- Startup time — `nvim --headless --startuptime`, 3 runs from `$HOME`.
- `:lsp restart` in `lspconfig.lua:22` was checked and **is valid** on 0.12 (`exists(":lsp") == 2`)
  — not flagged.

**Correction log**

- *Font fallback (§1)* — original finding was **wrong** and is retracted. It rested on
  `fc-match ":charset=<cp>"`, a family-less query that models nothing a terminal actually does.
  Re-checked with `fc-match -s "JetBrainsMono Nerd Font"` to walk the real fallback chain and
  test each entry for coverage; IAST resolves at position 2 to monospace Noto Sans Mono. The
  recommended fontconfig file was **not** created.

**Post-fix verification (P0)**

- `spellbadword()` over 10 seeded terms → none flagged; `teh` / `recieve` still flagged.
- `foldlevel()` on a test note → H1=1, H2=2, H3=3.
- `search()` with lower/exact/upper queries → confirms ignorecase + smartcase behaviour.
- Full config load, headless, no errors.

</details>
