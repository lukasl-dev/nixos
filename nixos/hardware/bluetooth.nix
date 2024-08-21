{ lib, config, ... }:

{
  options.bluetooth = {
    enable = lib.mkOption {
      type = with lib.types; bool;
      default = true;
      description = "Enable bluetooth support";
    };
  };

  hardware.bluetooth = {
    enable = config.bluetooth.enable;

    powerOnBoot = true;
  };
}
