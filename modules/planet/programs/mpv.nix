{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) mpv;
in
{
  options.planet.programs.mpv.enable = lib.mkOption {
    type = lib.types.bool;
    default = planet.desktop.enable;
    description = "Enable the mpv media player.";
  };

  config = lib.mkIf mpv.enable {
    environment.systemPackages = [ pkgs.mpv ];
  };
}
