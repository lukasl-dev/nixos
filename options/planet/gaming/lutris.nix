{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  lutris = config.planet.gaming.lutris;
in
{
  options.planet.gaming.lutris = {
    enable = lib.mkEnableOption "Enable lutris";
  };

  config = lib.mkIf lutris.enable {
    environment.systemPackages = [ pkgs-unstable.lutris ];
  };
}
