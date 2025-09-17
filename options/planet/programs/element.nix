{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  wm = config.planet.wm;

  element = config.planet.programs.element;
in
{
  options.planet.programs.element = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable element";
      example = "true";
    };
  };

  config = lib.mkIf element.enable {
    environment.systemPackages = [
      pkgs-unstable.element-desktop
    ];
  };
}
