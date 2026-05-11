{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) mpv;
in
{
  options.planet.programs = {
    mpv = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable mpv media player";
      };
    };
  };

  config = lib.mkIf mpv.enable {
    environment.systemPackages = [ pkgs.mpv ];
  };
}
