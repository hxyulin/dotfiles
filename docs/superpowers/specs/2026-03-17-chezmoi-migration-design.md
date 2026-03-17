# Dotfiles Migration to Chezmoi — Design Spec

## Problem

The current `setup.py` dotfiles manager handles symlinks and platform detection but lacks:
- Machine profiles (which configs go on which machine)
- Proper conflict resolution (just errors out)
- Templating (configs that vary per machine need manual edits)
- Secret encryption (SSH keys, API tokens not portable)
- Package list management (no declarative package installs)
- Shell config organization is ad-hoc

Target platforms: macOS (nix-darwin), CachyOS (Arch), Ubuntu/WSL, Windows.

## Solution

Replace `setup.py` with **chezmoi** — a cross-platform dotfiles manager with built-in templating, encryption, machine profiles, and conflict handling.

## Architecture

### Source Directory Structure

The chezmoi source (`~/.local/share/chezmoi/`) becomes the git repo:

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl              # Machine profile template
├── .chezmoiignore                  # Platform-conditional exclusions
├── install.sh                      # Bootstrap script (not managed by chezmoi)
├── CLAUDE.md
├── README.md
│
├── dot_config/
│   ├── aerospace/aerospace.toml            # macOS only, exact copy
│   ├── alacritty/alacritty.toml.tmpl       # Template (font varies)
│   ├── ghostty/config.tmpl                 # Template (font varies)
│   ├── nix-darwin/                         # macOS only, exact copies
│   │   ├── flake.nix
│   │   ├── flake.lock
│   │   └── rebuild.sh
│   ├── nvim/                               # Cross-platform, exact copies
│   │   ├── init.lua
│   │   ├── dot_editorconfig
│   │   ├── dot_stylua.toml
│   │   └── lua/...
│   ├── sketchybar/...                      # macOS only
│   ├── skhd/skhdrc                         # macOS only
│   ├── starship.toml                       # Cross-platform, exact copy
│   ├── clangd/config.yaml                  # Cross-platform
│   ├── hypr/hyprland.conf.tmpl             # CachyOS only (NEW)
│   └── sway/config.tmpl                    # CachyOS only (NEW)
│
├── dot_gitconfig.tmpl                      # NEW — email, signing per profile
├── dot_gitignore_global                    # NEW
├── dot_tmux.conf                           # Cross-platform, exact copy
├── dot_zshenv.tmpl                         # Template (pnpm path macOS-only)
├── dot_zprofile.tmpl                       # Template (homebrew macOS-only)
├── dot_zshrc                               # Cross-platform, exact copy
├── dot_Brewfile                            # macOS only (NEW)
│
├── private_dot_ssh/                        # NEW
│   ├── config.tmpl                         # Per-machine SSH hosts
│   └── encrypted_private_id_ed25519.age    # Encrypted SSH key
│
└── .chezmoiscripts/
    ├── run_once_before_install-age.sh.tmpl
    ├── run_onchange_darwin-packages.sh.tmpl
    ├── run_onchange_arch-packages.sh.tmpl
    ├── run_onchange_cargo-packages.sh.tmpl
    ├── run_onchange_nix-darwin-rebuild.sh.tmpl
    └── run_once_darwin-clangd-symlink.sh.tmpl
```

### Machine Profiles (`.chezmoi.toml.tmpl`)

Interactive prompts on `chezmoi init` collect:
- **profile**: `macos-personal`, `macos-work`, `cachyos`, `ubuntu-wsl`, `windows`
- **email**: Git commit email
- Derived: `fontSize`, `fontFamily`, feature flags

Feature flags control what gets installed:

| Feature | macos-personal | macos-work | cachyos | ubuntu-wsl | windows |
|---------|:-:|:-:|:-:|:-:|:-:|
| nix_darwin | Y | N | N | N | N |
| homebrew | Y | Y | N | N | N |
| aerospace | Y | Y | N | N | N |
| sketchybar | Y | Y | N | N | N |
| hyprland | N | N | Y | N | N |
| sway | N | N | Y | N | N |

### Templates

Files that vary per machine use `.tmpl` suffix with Go template syntax:
- **ghostty/config.tmpl**: `font-size`, `font-family`, macOS-specific titlebar
- **alacritty/alacritty.toml.tmpl**: font family/size (font name differs across OSes)
- **dot_zshenv.tmpl**: pnpm path (macOS only)
- **dot_zprofile.tmpl**: homebrew eval (macOS only)
- **dot_gitconfig.tmpl**: email, GPG signing (personal only)
- **private_dot_ssh/config.tmpl**: per-machine SSH hosts

### Encrypted Secrets (age)

- Each machine has its own age keypair at `~/.config/chezmoi/key.txt`
- All machine public keys listed as recipients in `.chezmoi.toml.tmpl`
- Files encrypted with `chezmoi add --encrypt`
- Encrypted files: SSH private keys, any API tokens

### Package Management Scripts

`run_onchange_` scripts re-run when their hash comment changes:
- **darwin-packages.sh.tmpl**: `brew bundle --file=~/.Brewfile`
- **arch-packages.sh.tmpl**: `sudo pacman -S --needed` from package list
- **cargo-packages.sh.tmpl**: `cargo install` from list
- **nix-darwin-rebuild.sh.tmpl**: `darwin-rebuild switch` when flake.nix changes

### Special Cases

**clangd**: Lives at `~/.config/clangd/` (Linux) but `~/Library/Preferences/clangd/` (macOS). Placed in `dot_config/clangd/` with a `run_once_` script to create a macOS symlink.

**nix-darwin**: Chezmoi places the flake files, a `run_onchange_` script triggers rebuild.

**nvim**: Entire directory is exact copies (no templates needed — machine-specific LSP config already handled by the existing `lsp_local.lua` override mechanism).

### Bootstrap

One-liner for new machines:
```bash
curl -fsSL https://raw.githubusercontent.com/hxyulin/dotfiles/main/install.sh | bash
```

The script: installs chezmoi + age, sets up age key (generate new or paste existing), runs `chezmoi init --apply`.

## Migration Plan

1. Install chezmoi, create `.chezmoi.toml.tmpl` + `.chezmoiignore`
2. `python3 setup.py uninstall` to remove existing symlinks
3. Add configs to chezmoi incrementally (exact copies first, then templates)
4. Add new configs (git, SSH, package lists, desktop env)
5. Add encrypted secrets and `run_onchange_` scripts
6. Create migration branch, restructure repo to chezmoi source layout
7. Validate: `chezmoi verify`, `chezmoi diff`, `chezmoi doctor`
8. Remove setup.py, update docs, test bootstrap on fresh env

## Verification

- `chezmoi doctor` — config health check
- `chezmoi verify` — all managed files match source
- `chezmoi diff` — no unexpected diffs
- `chezmoi managed` — lists all managed paths
- Test bootstrap in a container/VM for each target platform
- Verify encrypted files decrypt correctly on a second machine
