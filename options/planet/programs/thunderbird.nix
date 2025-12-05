{ config, lib, pkgs, ... }:

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
          package = pkgs.thunderbird-bin;
          profiles.default = {
            isDefault = true;
          };
        };
      }
    ];
  };
}
