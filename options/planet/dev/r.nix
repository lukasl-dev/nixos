{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.dev) R;
in
{
  options.planet.dev.R = {
    enable = lib.mkEnableOption "Enable R";
  };

  config = lib.mkIf R.enable {
    environment.systemPackages = [ pkgs.unstable.R ];
  };
}
