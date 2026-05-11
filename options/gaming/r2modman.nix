{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.gaming) r2modman;
in
{
  options.planet.gaming = {
    r2modman = {
      enable = lib.mkEnableOption "Enable r2modman";
    };
  };

  config = lib.mkIf r2modman.enable {
    environment.systemPackages = [ pkgs.unstable.r2modman ];
  };
}
