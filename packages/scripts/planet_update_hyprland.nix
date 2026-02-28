{ pkgs }:

pkgs.writeShellApplication {
  name = "planet_update_hyprland";
  runtimeInputs = with pkgs; [
    gh
    ripgrep
    gnused
    nix
  ];
  text = # bash
    ''
      set -euo pipefail

      tag="$(gh release view --repo hyprwm/Hyprland --json tagName --jq .tagName)"

      if ! rg -q 'github:hyprwm/Hyprland/v[0-9]+\.[0-9]+\.[0-9]+' flake.nix; then
        echo "Could not find hyprland input in flake.nix" >&2
        exit 1
      fi

      sed -Ei "s#github:hyprwm/Hyprland/v[0-9]+\.[0-9]+\.[0-9]+#github:hyprwm/Hyprland/''${tag}#" flake.nix
      echo "Updated flake.nix to ''${tag}"

      nix flake update hyprland
    '';
}
