#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <nixpkgs-ref> <option-path>" >&2
  echo "Example: $0 nixos-unstable services.openssh.enable" >&2
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
option_path=$(escape_nix_string "$2")

expr=$(cat <<EOF
let
  nixpkgs = builtins.getFlake "github:NixOS/nixpkgs/${ref}";
  pkgs = import nixpkgs {};
  eval = import "\${nixpkgs}/nixos/lib/eval-config.nix" {
    inherit pkgs;
    modules = [];
  };
  optionPath = "${option_path}";
  option = pkgs.lib.getAttrFromPath (pkgs.lib.splitString "." optionPath) eval.options;
in
{
  name = optionPath;
  description = if option ? description then (if builtins.isAttrs option.description && option.description ? text then option.description.text else if builtins.isString option.description then option.description else "") else "";
  type = if option ? type then (if builtins.isString option.type then option.type else if builtins.isAttrs option.type && option.type ? description then option.type.description else "") else "";
  default = if option ? default then (if builtins.isAttrs option.default && option.default ? text then option.default.text else builtins.toJSON option.default) else "";
  example = if option ? example then (if builtins.isAttrs option.example && option.example ? text then option.example.text else builtins.toJSON option.example) else "";
  declarations = if option ? declarations then option.declarations else [];
}
EOF
)

nix --extra-experimental-features "nix-command flakes" eval --json --impure --expr "$expr"
