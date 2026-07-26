{ config, lib, ... }:

let
  inherit (config) planet;
in
{
  options.planet.hardware.bluetooth.enable = lib.mkEnableOption "Bluetooth";

  config = lib.mkIf planet.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;
  };
}
