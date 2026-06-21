#!/usr/bin/env bash
set -euo pipefail

# Build & switch the nix-darwin system configuration.
sudo darwin-rebuild switch --flake ~/.config/nix-darwin#hxyulin-mac
