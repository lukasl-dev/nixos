{ config, lib, ... }:

let
  bluetooth = config.planet.hardware.bluetooth;
in
{
  options.planet.hardware.bluetooth = {
    enable = lib.mkEnableOption "Enable bluetooth";
  };

  config = lib.mkIf bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
