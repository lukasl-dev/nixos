{ config, lib, ... }:

let
  inherit (config.planet) display;
  inherit (config.planet.services) printing;
in
{
  options.planet.services.printing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = display.enable;
      description = "Enable printing";
    };
  };

  config = lib.mkIf printing.enable {
    services.printing.enable = true;
  };
}
