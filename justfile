default:
    @just --list

update-unstable:
    nix flake lock --update-input nixpkgs-unstable

vega:
    nixos-rebuild switch --flake .#vega
