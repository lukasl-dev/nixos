{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  bottles = config.planet.gaming.bottles;
in
{
  options.planet.gaming.bottles = {
    enable = lib.mkEnableOption "Enable bottles";
  };

  config = lib.mkIf bottles.enable {
    environment.systemPackages = [ pkgs-unstable.bottles ];
  };
}
