{
  config,
  lib,
  pkgs,
  ...
}:

let
  wm = config.planet.wm;

  feh = config.planet.programs.feh;
in
{
  options.planet.programs.feh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable feh image viewer";
    };
  };

  config = lib.mkIf feh.enable {
    environment.systemPackages = [ pkgs.feh ];
  };
}
