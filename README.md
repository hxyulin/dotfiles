# Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://chezmoi.io).

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/hxyulin/dotfiles/main/install.sh | bash
```

This installs chezmoi + age, prompts for your machine profile, and applies all configs.

## Supported Platforms

| Profile | OS | Window Manager | Notes |
|---|---|---|---|
| `macos-personal` | macOS | AeroSpace | Full setup: nix-darwin, Homebrew, signing |
| `macos-work` | macOS | AeroSpace | No nix-darwin, no commit signing |
| `cachyos` | Arch Linux | Hyprland / Sway | Pacman packages |
| `ubuntu-wsl` | Ubuntu (WSL) | — | Minimal, no desktop |
| `windows` | Windows | — | Minimal |

## What's Included

- **Terminal**: Ghostty, Alacritty (font/size templated per platform)
- **Shell**: Zsh with Starship prompt, Zoxide, exa
- **Editor**: Neovim (Lazy.nvim, Treesitter, LSP, Copilot)
- **macOS**: AeroSpace, Sketchybar, skhd, nix-darwin
- **Linux**: Hyprland, Sway (CachyOS placeholders)
- **Git**: Templated gitconfig (email, SSH signing)
- **Packages**: Declarative Brewfile, pacman list, cargo list
- **Secrets**: age-encrypted SSH keys

## Usage

```bash
chezmoi apply        # apply configs
chezmoi diff         # preview changes
chezmoi edit <file>  # edit a managed file
chezmoi update       # pull latest + apply
chezmoi doctor       # health check
```

## Adding a New Machine

1. Run the bootstrap script above
2. Select your machine profile when prompted
3. If you have encrypted secrets, paste your existing age key when prompted
4. Add the new machine's age public key to `.chezmoi.toml.tmpl` on an existing machine
5. Re-encrypt secrets: `chezmoi re-add`
