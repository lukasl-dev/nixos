default:
  @just --list

vega:
    nixos-rebuild switch --flake .#vega
