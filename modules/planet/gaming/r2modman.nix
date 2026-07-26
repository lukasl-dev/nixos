{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
in
{
  options.planet.gaming.r2modman.enable = lib.mkEnableOption "r2modman";

  config = lib.mkIf planet.gaming.r2modman.enable {
    environment.systemPackages = [ pkgs.r2modman ];
  };
}
