{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) thunderbird;
in
{
  options.planet.programs = {
    thunderbird = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable thunderbird";
        example = "true";
      };
    };
  };

  config = lib.mkIf thunderbird.enable {
    planet.hm = [
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
