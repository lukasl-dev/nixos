{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  wm = config.planet.wm;

  clipse = config.planet.services.clipse;
in
{
  options.planet.services.clipse = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable clipse";
      default = wm.enable;
      example = "true";
    };
  };

  config = lib.mkIf clipse.enable {
    environment.systemPackages = [ pkgs-unstable.clipse ];
  };
}
