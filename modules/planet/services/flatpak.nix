{ config, lib, ... }:

let
  inherit (config) planet;
in
{
  options.planet.services.flatpak.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Enable Flatpak.";
  };

  config = lib.mkIf planet.services.flatpak.enable {
    services.flatpak.enable = true;
  };
}
