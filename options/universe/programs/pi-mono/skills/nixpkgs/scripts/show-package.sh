#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <nixpkgs-ref> <package-attr>" >&2
  echo "Example: $0 nixos-unstable hello" >&2
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
package_attr=$(escape_nix_string "$2")

expr=$(cat <<EOF
let
  nixpkgs = builtins.getFlake "github:NixOS/nixpkgs/${ref}";
  pkgs = import nixpkgs {};
  attrPath = "${package_attr}";
  pkg = pkgs.lib.getAttrFromPath (pkgs.lib.splitString "." attrPath) pkgs;
  meta = if pkg ? meta then pkg.meta else {};
in
{
  attrPath = attrPath;
  name = if pkg ? name then pkg.name else "";
  pname = if pkg ? pname then pkg.pname else "";
  version = if pkg ? version then pkg.version else "";
  description = if meta ? description then meta.description else "";
  homepage = if meta ? homepage then meta.homepage else null;
  license = if meta ? license then meta.license else null;
  platforms = if meta ? platforms then meta.platforms else [];
  broken = if meta ? broken then meta.broken else false;
  insecure = if meta ? insecure then meta.insecure else false;
  available = if meta ? available then meta.available else null;
}
EOF
)

nix --extra-experimental-features "nix-command flakes" eval --json --impure --expr "$expr"
