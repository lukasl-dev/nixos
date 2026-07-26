{ config, lib, ... }:

let
  inherit (config) planet;
in
{
  options.planet = {
    time = {
      zone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Vienna";
      };
    };
  };

  config = {
    time.timeZone = planet.time.zone;
  };
}
