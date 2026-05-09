#!/usr/bin/env bash
set -euo pipefail

repo_root=${1:?missing repo root}
pkg_root=${2:?missing pi-mono package path}

extensions_dir="$repo_root/options/universe/programs/pi-mono/extensions"
node_modules_dir="$extensions_dir/node_modules"

mkdir -p \
  "$node_modules_dir/@mariozechner" \
  "$node_modules_dir/@sinclair"

ln -sfn \
  "$pkg_root/lib/node_modules/@mariozechner/pi-coding-agent" \
  "$node_modules_dir/@mariozechner/pi-coding-agent"
ln -sfn \
  "$pkg_root/lib/node_modules/@mariozechner/pi-ai" \
  "$node_modules_dir/@mariozechner/pi-ai"
ln -sfn \
  "$pkg_root/lib/node_modules/@mariozechner/pi-tui" \
  "$node_modules_dir/@mariozechner/pi-tui"
ln -sfn \
  "$pkg_root/lib/node_modules/@sinclair/typebox" \
  "$node_modules_dir/@sinclair/typebox"

echo "pi-mono extension node_modules ready: $extensions_dir"
