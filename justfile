default:
    @just --list

flake-update:
    nix flake update

vega-switch:
    nixos-rebuild switch --flake .#vega

orion-switch:
    nixos-rebuild switch --flake .#orion

sirius-switch:
    nixos-rebuild switch --flake .#sirius
