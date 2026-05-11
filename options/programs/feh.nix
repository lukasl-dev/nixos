{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) feh;
in
{
  options.planet.programs = {
    feh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable feh image viewer";
      };
    };
  };

  config = lib.mkIf feh.enable {
    environment.systemPackages = [ pkgs.feh ];
  };
}
