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
On `chezmoi init`, the user selects a profile: `macbook`, `arch`, or `ubuntu`. This drives feature flags and template values (font size, font family, platform-specific blocks).

Flags: `isDarwin` (macbook), `isArch` (arch), `isUbuntu` (ubuntu), `isLinux` (arch or ubuntu)

Config: `~/.config/chezmoi/chezmoi.toml` (generated from `.chezmoi.toml.tmpl`)

## Repository Layout

This repo IS the chezmoi source directory (`~/.local/share/chezmoi/`).

```
.chezmoi.toml.tmpl          Machine profile template (prompts + feature flags)
.chezmoiignore              Platform-conditional file exclusions
install.sh                  Bootstrap script (installs chezmoi + rustup + age)

dot_config/
├── apt-packages.txt        Ubuntu package list
├── bat/                    Bat (cat replacement) config
├── btop/                   Btop system monitor config
├── cargo-packages.txt.tmpl Cargo install list (templated — ubuntu gets extras)
├── clangd/                 ClangD config
├── fd/                     fd (find replacement) ignore patterns
├── fish/                   Fish shell config (all platforms)
│   ├── config.fish         Interactive guard, greeting
│   └── conf.d/             Auto-loaded config snippets
├── atuin/                  Shell history config
├── lazygit/                Git TUI config (delta pager integration)
├── yazi/                   Terminal file manager config
├── ghostty/                Ghostty terminal (templated — font, titlebar)
├── hypr/                   Arch only — Hyprland (placeholder)
├── nix-darwin/             macOS only — Nix-darwin flake
├── nvim/                   Neovim config (Lazy.nvim, cross-platform)
├── pacman-packages.txt     Arch package list
├── ripgrep/                Ripgrep config (smart-case, ignores)
├── starship.toml           Starship prompt
├── sway/                   Arch only — Sway (placeholder)

dot_gitconfig.tmpl          Git config (templated — email, signing, delta)
dot_gitignore_global        Global gitignore
dot_tmux.conf               Tmux config
dot_config/shell/env.sh.tmpl  Shared env/PATH for bash & zsh (single source of truth)
dot_zshrc                   Zsh interactive config (history, completion, aliases)
dot_bashrc                  Bash interactive config (sources env.sh, then interactive)
dot_zshenv.tmpl             Zsh env (typeset -U PATH, sources env.sh)
dot_zprofile.tmpl           Zsh login (macOS: re-sources env.sh after path_helper)
dot_bash_profile.tmpl       Bash login (sets BASH_ENV, sources .bashrc)

private_dot_ssh/            SSH config (templated)
.chezmoiscripts/            Auto-run scripts (package install, rustup, fnm, nix rebuild)
```

### Templated Files (`.tmpl`)
Files ending in `.tmpl` use Go template syntax. Template data comes from two sources:

**`.chezmoi.toml.tmpl`** — prompted/derived, rendered only at `chezmoi init`:
- `{{ .fontFamily }}`, `{{ .fontSize }}` — font settings per platform
- `{{ .isDarwin }}`, `{{ .isArch }}`, `{{ .isUbuntu }}`, `{{ .isLinux }}` — platform conditionals
- `{{ .email }}` — identity settings

**`.chezmoidata.toml`** — static constants, read on EVERY operation (no re-init needed):
- `{{ .vulkanVersion }}` — Vulkan SDK version; bump once, used by env.sh + fish

### Shell env architecture
`~/.config/shell/env.sh` is the single source of truth for env/PATH, shared by
**bash and zsh** (fish keeps its own copy in `conf.d/` — different syntax):
- `.zshenv` → `typeset -U PATH`, then sources `env.sh` (covers non-interactive `zsh -c`)
- `.zprofile` (macOS) → re-sources `env.sh` after `path_helper` reorders PATH
- `.bashrc` → sources `env.sh` above its interactive guard; `.bash_profile` sets
  `BASH_ENV=~/.bashrc` so non-interactive `bash -c` (agents/scripts) get it too

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
- **Colorscheme**: Cyberdream (Neovim)
- **Font**: JetBrains Mono Nerd Font everywhere (templated per platform)
- **macOS system**: dark mode, tap-to-click, three-finger drag, nvim as default editor (see `dot_config/nix-darwin/flake.nix`)
