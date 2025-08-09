{
  config,
  lib,
  pkgs,
  ...
}:

let
  wm = config.planet.wm;

  mpv = config.planet.programs.mpv;
in
{
  options.planet.programs.mpv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable mpv media player";
    };
  };

  config = lib.mkIf mpv.enable {
    environment.systemPackages = [ pkgs.mpv ];
  };
}
