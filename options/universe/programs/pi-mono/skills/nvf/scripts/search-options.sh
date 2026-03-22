#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 <nvf-ref> <query> [limit]" >&2
  echo "Example: $0 main vim.lsp 20" >&2
  exit 1
fi

escape_nix_string() {
  local s="$1"
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

ref=$(escape_nix_string "$1")
query=$(escape_nix_string "$2")
limit="${3:-20}"

expr=$(cat <<EOF
let
  flake = builtins.getFlake "github:NotAShelf/nvf/${ref}";
  pkgs = import <nixpkgs> {};
  eval = flake.lib.neovimConfiguration {
    inherit pkgs;
    modules = [];
  };
  optionsList = pkgs.lib.optionAttrSetToDocList eval.options;
  query = "${query}";
  limit = ${limit};
  results = builtins.filter (opt: pkgs.lib.hasInfix query opt.name) optionsList;
in
builtins.map (opt: {
  name = opt.name;
  description = if opt ? description then (if builtins.isAttrs opt.description && opt.description ? text then opt.description.text else if builtins.isString opt.description then opt.description else "") else "";
  type = if opt ? type then (if builtins.isString opt.type then opt.type else if builtins.isAttrs opt.type && opt.type ? description then opt.type.description else "") else "";
  default = if opt ? default then (if builtins.isAttrs opt.default && opt.default ? text then opt.default.text else builtins.toJSON opt.default) else "";
}) (pkgs.lib.take limit results)
EOF
)

nix --extra-experimental-features "nix-command flakes" eval --json --impure --expr "$expr"
