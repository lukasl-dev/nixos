{ config, lib, ... }:

let
  inherit (config.planet.services) flatpak;
in
{
  options.planet.services.flatpak = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable flatpak";
      default = false;
      example = "true";
    };
  };

  config = lib.mkIf flatpak.enable {
    services.flatpak.enable = true;
  };
}
