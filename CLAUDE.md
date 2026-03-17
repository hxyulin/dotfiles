# CLAUDE.md

## Setup

Dotfiles are managed with [chezmoi](https://chezmoi.io).

### Bootstrap (new machine)
```bash
curl -fsSL https://raw.githubusercontent.com/hxyulin/dotfiles/main/install.sh | bash
```

### Common Commands
```bash
chezmoi apply              # apply all configs
chezmoi diff               # preview changes before applying
chezmoi edit <file>        # edit a managed config
chezmoi add <file>         # add a new file to chezmoi
chezmoi managed            # list all managed files
chezmoi doctor             # health check
chezmoi cd                 # cd to chezmoi source directory
```

### Machine Profiles
On `chezmoi init`, the user selects a profile: `macos-personal`, `macos-work`, `cachyos`, `ubuntu-wsl`, or `windows`. This drives feature flags and template values (font size, font family, platform-specific blocks).

Config: `~/.config/chezmoi/chezmoi.toml` (generated from `.chezmoi.toml.tmpl`)

## Repository Layout

This repo IS the chezmoi source directory (`~/.local/share/chezmoi/`).

```
.chezmoi.toml.tmpl          Machine profile template (prompts + feature flags)
.chezmoiignore              Platform-conditional file exclusions
install.sh                  Bootstrap script (installs chezmoi + age)

dot_config/
├── aerospace/              macOS only — AeroSpace window manager
├── alacritty/              Alacritty terminal (templated — font varies)
├── cargo-packages.txt      Cargo install list
├── clangd/                 ClangD config
├── ghostty/                Ghostty terminal (templated — font, titlebar)
├── hypr/                   CachyOS only — Hyprland (placeholder)
├── nix-darwin/             macOS-personal only — Nix-darwin flake
├── nvim/                   Neovim config (Lazy.nvim, cross-platform)
├── pacman-packages.txt     Arch/CachyOS package list
├── sketchybar/             macOS only — Status bar
├── starship.toml           Starship prompt
├── skhd/                   macOS only — Hotkey daemon
├── sway/                   CachyOS only — Sway (placeholder)

dot_Brewfile                macOS Homebrew packages
dot_gitconfig.tmpl          Git config (templated — email, signing)
dot_gitignore_global        Global gitignore
dot_tmux.conf               Tmux config
dot_zshrc                   Zsh interactive config
dot_zshenv.tmpl             Zsh env (templated — pnpm path macOS-only)
dot_zprofile.tmpl           Zsh profile (templated — homebrew macOS-only)

private_dot_ssh/            SSH config (templated)
.chezmoiscripts/            Auto-run scripts (package install, nix rebuild)
```

### Templated Files (`.tmpl`)
Files ending in `.tmpl` use Go template syntax. Template data comes from `.chezmoi.toml.tmpl`:
- `{{ .fontFamily }}`, `{{ .fontSize }}` — font settings per platform
- `{{ .isDarwin }}`, `{{ .isCachyOS }}`, etc. — platform conditionals
- `{{ .email }}`, `{{ .isPersonal }}` — identity/profile settings

### Chezmoi Naming Conventions
- `dot_` prefix → `.` in target (e.g., `dot_config/` → `~/.config/`)
- `private_` prefix → restricted permissions
- `encrypted_` prefix → age-encrypted files
- `.tmpl` suffix → Go template processing
- `run_onchange_` scripts → re-run when content hash changes
- `run_once_` scripts → run only on first apply

## Neovim Config Architecture (dot_config/nvim/)

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

- **Lua formatting**: stylua — 100 column width, 2-space indent, double quotes, sorted requires (`dot_config/nvim/dot_stylua.toml`)
- **Editor config**: 4-space default; 2-space for JS/TS/JSON/Lua (`dot_config/nvim/dot_editorconfig`)
- **Colorscheme**: Cyberdream (Neovim), Ayu Dark (Alacritty)
- **Font**: JetBrains Mono Nerd Font everywhere (templated per platform)
- **macOS system**: dark mode, tap-to-click, three-finger drag, nvim as default editor (see `dot_config/nix-darwin/flake.nix`)
