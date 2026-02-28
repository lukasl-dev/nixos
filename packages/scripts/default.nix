{ pkgs }:

[
  (import ./planet_update_helium.nix { inherit pkgs; })
  (import ./planet_update_hyprland.nix { inherit pkgs; })
]
