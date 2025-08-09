{ config, lib, ... }:

let
  ghostty = config.planet.caches.ghostty;
in
{
  options.planet.caches.ghostty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.planet.programs.ghostty.enable;
      description = "Enable Ghostty binary cache for Nix packages.";
    };
  };

  config = lib.mkIf ghostty.enable {
    nix.settings = {
      substituters = [
        "https://ghostty.cachix.org"
      ];
      trusted-public-keys = [
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
    };
  };
}
