# CLAUDE.md

## Setup

Configs are managed via `setup.py` which creates symlinks from this repo into `~/.config` (or `%APPDATA%` on Windows).

```bash
python3 setup.py list              # show available configs for this platform
python3 setup.py info <config>     # show details for a config
python3 setup.py install [config]  # install one or all configs (symlinks)
python3 setup.py uninstall [config] # remove symlinks only
```

Nix-darwin (macOS system config):
```bash
sudo darwin-rebuild switch --flake ~/.config/nix-darwin/flake.nix
```

## Repository Layout

```
aerospace/       AeroSpace window manager (aerospace.toml)
alacritty/       Alacritty terminal (Ayu Dark theme)
ghostty/         Ghostty terminal
nix-darwin/      Nix-darwin flake (aarch64-darwin, homebrew integration)
nvim/            Neovim config (primary — Lazy.nvim)
nvim_nvchad/     Alternative NvChad-based config
sketchybar/      Status bar (sketchybarrc, items/, plugins/)
skhd/            Simple Hotkey Daemon
.tmux.conf       Tmux (tpm, resurrect, yank)
starship.toml    Starship prompt
setup.py         Symlink manager
```

Platform-aware: `setup.py` detects Darwin/Linux/Windows and adjusts config paths. Some configs (e.g. nix-darwin) are platform-specific.

## Neovim Config Architecture (nvim/)

Entry point: `init.lua` — sets leader to space, bootstraps Lazy.nvim, loads config modules.

```
lua/
├── config/              Core settings loaded by init.lua
│   ├── options.lua      Vim options (4-space tabs, relative line numbers)
│   ├── keymaps.lua      Global keymaps (; → :, - → Oil)
│   ├── autocmd.lua      Autocommands + LSP keybinds (gd, gr, K, F2, F3)
│   ├── lspconfig.lua    LSP server setup
│   └── <plugin>/        Per-plugin opts.lua / keys.lua
│       ├── blink/       Completion config
│       ├── snacks/      Snacks.nvim config
│       ├── harpoon/     Navigation keybinds
│       └── ...
└── plugins/             Lazy.nvim plugin specs (auto-imported)
    ├── completion.lua   Treesitter, blink.cmp, Copilot
    ├── editor.lua       Snacks, Cyberdream, Lualine, Oil, Gitsigns
    ├── formatting.lua   Conform.nvim
    └── lsp.lua          nvim-lspconfig, Mason, Lazydev, Sidekick
```

Plugin config pattern: plugin specs in `plugins/` reference opts/keys from `config/<plugin>/` to keep specs clean.

## Conventions

- **Lua formatting**: stylua — 100 column width, 2-space indent, double quotes, sorted requires (`nvim/.stylua.toml`)
- **Editor config**: 4-space default; 2-space for JS/TS/JSON/Lua (`nvim/.editorconfig`)
- **Colorscheme**: Cyberdream (Neovim), Ayu Dark (Alacritty)
- **Font**: JetBrains Mono Nerd Font everywhere (installed via nix, configured in ghostty/alacritty/sketchybar)
- **macOS system**: dark mode, tap-to-click, three-finger drag, nvim as default editor (see `nix-darwin/flake.nix`)
