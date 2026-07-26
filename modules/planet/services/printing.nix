{ config, lib, ... }:

let
  inherit (config) planet;
in
{
  options.planet.services.printing.enable = lib.mkOption {
    type = lib.types.bool;
    default = planet.desktop.enable;
    description = "Enable printing.";
  };

  config = lib.mkIf planet.services.printing.enable {
    services.printing.enable = true;
  };
}
