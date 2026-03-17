#!/bin/bash
set -euo pipefail

# Dotfiles bootstrap script
# Usage: curl -fsSL https://raw.githubusercontent.com/hxyulin/dotfiles/main/install.sh | bash

REPO="https://github.com/hxyulin/dotfiles.git"

echo "=== Dotfiles Bootstrap ==="
echo ""

# --- Install chezmoi ---
if ! command -v chezmoi &>/dev/null; then
  echo "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
fi

# --- Install age ---
if ! command -v age &>/dev/null; then
  echo "Installing age..."
  case "$(uname -s)" in
    Darwin)
      if command -v brew &>/dev/null; then
        brew install age
      else
        echo "Please install Homebrew first: https://brew.sh"
        exit 1
      fi
      ;;
    Linux)
      if command -v pacman &>/dev/null; then
        sudo pacman -S --needed --noconfirm age
      elif command -v apt-get &>/dev/null; then
        sudo apt-get install -y age
      else
        echo "Please install age manually: https://github.com/FiloSottile/age"
        exit 1
      fi
      ;;
    *)
      echo "Please install age manually: https://github.com/FiloSottile/age"
      exit 1
      ;;
  esac
fi

# --- Set up age key ---
AGE_KEY="$HOME/.config/chezmoi/key.txt"
if [ ! -f "$AGE_KEY" ]; then
  echo ""
  echo "No age key found at $AGE_KEY"
  echo "Options:"
  echo "  1) Generate a new key (new machine)"
  echo "  2) Paste an existing key (existing machine)"
  echo ""
  read -rp "Choice [1/2]: " choice

  mkdir -p "$(dirname "$AGE_KEY")"

  case "$choice" in
    2)
      echo "Paste your age private key (AGE-SECRET-KEY-...), then press Enter:"
      read -r key
      echo "$key" > "$AGE_KEY"
      chmod 600 "$AGE_KEY"
      echo "Key saved."
      echo ""
      echo "IMPORTANT: Add this machine's public key to .chezmoi.toml.tmpl recipients"
      echo "and re-encrypt secrets with: chezmoi re-add"
      ;;
    *)
      age-keygen -o "$AGE_KEY" 2>&1
      chmod 600 "$AGE_KEY"
      echo ""
      echo "New key generated. Add the public key above to .chezmoi.toml.tmpl recipients"
      echo "on an existing machine, then re-encrypt secrets with: chezmoi re-add"
      ;;
  esac
fi

# --- Init and apply ---
echo ""
echo "Initializing chezmoi..."
chezmoi init --apply "$REPO"

echo ""
echo "=== Bootstrap complete ==="
echo "Run 'chezmoi diff' to verify, 'chezmoi apply' to re-apply."
