#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <nixpkgs-ref> <query>" >&2
  echo "Example: $0 nixos-unstable ripgrep" >&2
  exit 1
fi

ref="$1"
query="$2"

nix --extra-experimental-features "nix-command flakes" search "github:NixOS/nixpkgs/${ref}" "$query"
