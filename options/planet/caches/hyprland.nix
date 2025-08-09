{ config, lib, ... }:

let
  hyprland = config.planet.caches.hyprland;
in
{
  options.planet.caches.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.planet.wm.hyprland.enable;
      description = "Enable Hyprland cache for Nix packages.";
    };
  };

  config = lib.mkIf hyprland.enable {
    nix.settings = {
      substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };
}
