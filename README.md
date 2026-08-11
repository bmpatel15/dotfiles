# dotfiles

Personal configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Runs on an Arch/Omarchy Linux desktop and a MacBook Pro.

## Layout

Each top-level directory is a **stow package**. Inside it, paths mirror their
location relative to `$HOME`:

```
dotfiles/
└── nvim/
    └── .config/
        └── nvim/          ->  ~/.config/nvim
```

## Install

```bash
git clone git@github.com:<you>/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow nvim
```

`stow nvim` symlinks `~/dotfiles/nvim/.config/nvim` to `~/.config/nvim`.
To preview without writing anything: `stow -n -v nvim`.
To remove: `stow -D nvim`.

> If `~/.config/nvim` already exists as a real directory, stow refuses to link.
> Move it aside first: `mv ~/.config/nvim ~/.config/nvim.bak`.

---

## Neovim

A hand-rolled config (not a distro) built around markdown/Obsidian note-taking,
Python, and Bash. Leader is `<Space>`.

### Prerequisites

| | Linux (Arch) | macOS |
|---|---|---|
| Neovim ≥ 0.11 | `pacman -S neovim` | `brew install neovim` |
| git, curl | usually present | `brew install git curl` |
| C compiler (treesitter) | `base-devel` | `xcode-select --install` |
| ripgrep, fd (pickers) | `pacman -S ripgrep fd` | `brew install ripgrep fd` |
| Node (bash-language-server) | `pacman -S nodejs npm` | `brew install node` |
| Nerd Font | `ttf-jetbrains-mono-nerd` | `brew install --cask font-jetbrains-mono-nerd-font` |
| Terminal font set to it | — | set in Terminal/iTerm/Ghostty prefs |

Everything else (LSP servers, formatters, linters) installs itself through Mason
on first launch. Plugins install themselves through lazy.nvim.

First run will be slow — treesitter compiles parsers, Mason downloads servers,
and `fff.nvim` fetches a prebuilt Rust binary for the platform. Let it finish,
then restart. `:checkhealth` if anything looks off.

### Machine-specific paths

None. The Obsidian vault sits at `~/Documents/BigB-PKM` on every machine, and
`~` expands correctly on both platforms, so the config is byte-identical across
Linux and macOS. The single definition lives in `lua/bigb/util.lua`.

### Notes on portability

- **`lazy-lock.json` is committed** on purpose, so both machines run identical
  plugin versions. `:Lazy update` bumps it; commit the result to move the other
  machine forward.
- **`spell/en.utf-8.add.spl` is NOT committed.** It is a compiled artifact,
  rebuilt automatically the first time a markdown buffer opens. Edit the plain
  `spell/en.utf-8.add` (or use `zg`) and it recompiles on next launch.
- **Mason binaries and plugin code live in `~/.local/share/nvim`**, outside this
  repo, so nothing platform-specific is ever committed.

### Layout

```
lua/bigb/
├── core/        options, keymaps
├── util.lua     shared paths + machine detection
└── plugins/     one file per plugin
after/ftplugin/  per-filetype settings (markdown, python, sh)
spell/           personal dictionary
```

`CONFIG-REVIEW.md` inside the nvim package is a written audit of the config —
what it does well, what is missing, and a prioritised list of what to add next.
