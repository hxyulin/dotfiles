# Neovim Configuration

A modern Neovim config built on **Lazy.nvim** with full LSP, debugging, git workflow, and AI-assisted coding support. Targets **Lua**, **C/C++**, and **Rust** development.

## Quick Start

```bash
# From the dotfiles root
python3 setup.py install nvim
```

Open Neovim and Lazy.nvim will automatically install all plugins on first launch. Run `:Lazy` to check status and `:checkhealth` to verify everything is working.

Leader key is **Space**. Press `<Space>` and wait to see all available groups via which-key.

## Plugin Overview

| Plugin | Purpose |
|---|---|
| **lazy.nvim** | Plugin manager (auto-bootstrap) |
| **snacks.nvim** | Picker, explorer, terminal, notifications, dashboard, lazygit, scratch buffers, and more |
| **cyberdream.nvim** | Colorscheme |
| **lualine.nvim** | Statusline |
| **oil.nvim** | File explorer (buffer-based, `-` to open) |
| **which-key.nvim** | Keymap discovery popup |
| **harpoon** | Quick file navigation / bookmarks |
| **arena.nvim** | Buffer switcher |
| **todo-comments.nvim** | Highlight and navigate TODO/FIXME/HACK comments |
| **nvim-lspconfig** | LSP client configuration |
| **mason.nvim** | LSP/DAP/formatter installer |
| **mason-lspconfig** | Bridge between Mason and lspconfig |
| **lazydev.nvim** | Lua LSP workspace library for Neovim API |
| **blink.cmp** | Completion engine (super-tab preset) |
| **copilot.vim** | GitHub Copilot |
| **sidekick.nvim** | AI CLI integration (Claude, etc.) |
| **conform.nvim** | Formatting (stylua, prettier, black) |
| **nvim-treesitter** | Syntax highlighting and indentation |
| **gitsigns.nvim** | Git hunk signs, staging, blame |
| **diffview.nvim** | Side-by-side git diffs and file history |
| **trouble.nvim** | Diagnostics panel, symbols, quickfix |
| **noice.nvim** | Modern cmdline, messages, and LSP UI |
| **nvim-dap** | Debug Adapter Protocol client |
| **nvim-dap-ui** | Debug UI (auto open/close) |
| **nvim-dap-virtual-text** | Inline variable values while debugging |
| **mason-nvim-dap** | Auto-install debug adapters (codelldb) |
| **atone.nvim** | Undo tree visualization |
| **mini.icons** | Icon provider |

## LSP Servers

Installed automatically via Mason:

- **lua_ls** — Lua
- **clangd** — C / C++
- **rust_analyzer** — Rust

## Treesitter Parsers

`lua`, `vim`, `vimdoc`, `c`, `cpp`, `rust`, `markdown`, `markdown_inline`, `json`, `yaml`, `toml`, `bash`

## Keybindings

Leader key: **Space**

### Global

| Key | Action |
|---|---|
| `;` | Enter command mode (same as `:`) |
| `-` | Open parent directory (Oil) |
| `<` / `>` (visual) | Indent and stay in visual mode |

### Find (`<leader>f`)

| Key | Action |
|---|---|
| `ff` | Find files |
| `fw` | Live grep |
| `fb` | Buffers |
| `fh` | Help tags |
| `fr` | Recent files |
| `fc` | Find config files |
| `fg` | Git files |
| `fs` | LSP symbols |
| `fd` | Diagnostics |
| `f/` | Grep open buffers |

### Git (`<leader>g`)

| Key | Action |
|---|---|
| `gg` | LazyGit |
| `gb` | Git browse (open in browser) |
| `gf` | LazyGit current file history |
| `gL` | LazyGit log |
| `gd` | Diffview open |
| `gh` | File history (current file) |
| `gH` | File history (all) |
| `gc` | Diffview close |
| `gs` | Stage hunk (n/v) |
| `gr` | Reset hunk (n/v) |
| `gS` | Stage buffer |
| `gu` | Undo stage hunk |
| `gR` | Reset buffer |
| `gp` | Preview hunk |
| `gB` | Blame line (full) |
| `gl` | Toggle line blame |
| `]c` / `[c` | Next / prev hunk |

### LSP (`<leader>l` and `g` prefix)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation |
| `gK` | Signature help |
| `<C-k>` (insert) | Signature help |
| `<leader>ld` | Show line diagnostics |
| `<leader>lr` | Rename symbol |
| `<leader>la` | Code action (n/v) |
| `<leader>lf` | Format document |
| `<leader>li` | LSP info |
| `<leader>lR` | Restart LSP |
| `<F2>` | Rename (legacy) |
| `<F3>` | Format (legacy) |

### Debug (`<leader>d`)

| Key | Action |
|---|---|
| `dc` | Continue |
| `do` | Step over |
| `di` | Step into |
| `dO` | Step out |
| `db` | Toggle breakpoint |
| `dB` | Conditional breakpoint |
| `dl` | Log point |
| `dr` | Open REPL |
| `du` | Toggle DAP UI |
| `dR` | Run last |
| `dt` | Terminate |
| `de` | Evaluate expression (n/v) |

### Trouble (`<leader>x`)

| Key | Action |
|---|---|
| `xx` | Diagnostics |
| `xX` | Buffer diagnostics |
| `xs` | Symbols |
| `xl` | LSP defs/refs |
| `xL` | Location list |
| `xQ` | Quickfix list |

### Harpoon (`<leader>h`)

| Key | Action |
|---|---|
| `hm` | Mark file |
| `hh` | Toggle quick menu |
| `hn` | Next file |
| `hp` | Previous file |

### AI / Sidekick (`<leader>a`)

| Key | Action |
|---|---|
| `aa` | Toggle Sidekick CLI |
| `as` | Select CLI |
| `ad` | Detach CLI session |
| `at` | Send this (n/x) |
| `af` | Send file |
| `av` | Send visual selection (x) |
| `ap` | Select prompt (n/x) |
| `ac` | Toggle Claude |
| `<C-.>` | Toggle Sidekick (all modes) |
| `<Tab>` | Apply next edit suggestion |

### Terminal (`<leader>t`)

| Key | Action |
|---|---|
| `tt` | Toggle terminal (n/t) |

### Notes (`<leader>n`)

| Key | Action |
|---|---|
| `ns` | Open scratch buffer |
| `nS` | Select scratch buffer |
| `nh` | Notification history |

### Other

| Key | Action |
|---|---|
| `<leader>e` | File explorer (Snacks) |
| `<leader>j` | Toggle Arena (buffer switcher) |
| `<leader>?` | Buffer local keymaps |
| `<leader>un` | Dismiss all notifications |
| `]t` / `[t` | Next / prev TODO comment |

## Editor Options

- 4-space tabs (expandtab), 2-space for Lua/JS/TS/JSON via `.editorconfig`
- Relative line numbers with cursorline highlight
- Persistent undo (`undofile`)
- System clipboard sync (`unnamedplus`)
- `signcolumn = "yes"` (no layout shift)
- `scrolloff = 8` / `sidescrolloff = 8`
- Smart case search, incremental search
- Splits open right and below
- `updatetime = 250`, `timeoutlen = 300` (snappy which-key)
- Substitution preview in split (`inccommand = "split"`)
- No line wrap, no mode display (lualine handles it)

## Directory Structure

```
nvim/
├── init.lua                    Entry point (leader, lazy bootstrap, module loading)
├── .editorconfig               Per-filetype indent rules
├── .stylua.toml                Lua formatter config
└── lua/
    ├── config/                 Core settings and per-plugin config
    │   ├── options.lua         Vim options
    │   ├── keymaps.lua         Global keymaps
    │   ├── autocmd.lua         Autocommands + LSP keybinds
    │   ├── lspconfig.lua       LSP server setup (mason-lspconfig)
    │   ├── snacks/             Snacks opts + keys
    │   ├── harpoon/            Harpoon keys
    │   ├── blink/              Completion opts
    │   ├── treesitter/         Treesitter opts
    │   ├── trouble/            Trouble keys
    │   ├── dap/                DAP adapters + keys
    │   ├── lualine/            Statusline opts
    │   ├── arena/              Arena opts
    │   ├── mason/              Mason opts
    │   ├── lazydev/            Lazydev opts
    │   └── todo-comments/      Todo-comments keys
    └── plugins/                Lazy.nvim plugin specs (auto-imported)
        ├── completion.lua      Treesitter, blink.cmp, Copilot
        ├── editor.lua          Snacks, Cyberdream, Lualine, Oil, Which-key, Gitsigns, Diffview, Harpoon, Arena, Todo-comments
        ├── formatting.lua      Conform.nvim
        ├── lsp.lua             nvim-lspconfig, Mason, Lazydev, Sidekick
        ├── ui.lua              Trouble, Noice
        └── dap.lua             nvim-dap, dap-ui, virtual-text, mason-nvim-dap
```
