{ config, lib, ... }:

let
  nix-community = config.planet.caches.nix-community;
in
{
  options.planet.caches.nix-community = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Nix Community binary cache for Nix packages.";
    };
  };

  config = lib.mkIf nix-community.enable {
    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
