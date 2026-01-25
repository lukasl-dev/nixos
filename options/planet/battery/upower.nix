{ config, lib, ... }:

let
  inherit (config.planet.battery) upower;
in
{
  options.planet.battery.upower = {
    enable = lib.mkEnableOption "Enable cupower";
  };

  config = lib.mkIf upower.enable {
    services.upower.enable = true;
  };
}
