{ config, lib, ... }:

let
  wm = config.planet.wm;

  thunderbird = config.planet.programs.thunderbird;
in
{
  options.planet.programs.thunderbird = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable thunderbird";
      example = "true";
    };
  };

  config = lib.mkIf thunderbird.enable {
    universe.hm = [
      {
        programs.thunderbird = {
          enable = true;
          profiles.default = {
            isDefault = true;
          };
        };
      }
    ];
  };
}
