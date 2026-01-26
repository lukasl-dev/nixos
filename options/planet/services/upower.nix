{ config, lib, ... }:

let
  inherit (config.planet.services) upower;
in
{
  options.planet.services.upower = {
    enable = lib.mkEnableOption "Enable upower";
  };

  config = lib.mkIf upower.enable {
    services.upower.enable = true;
  };
}
