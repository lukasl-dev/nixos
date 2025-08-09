{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  wm = config.planet.wm;
in
{
  options.planet.programs.obsidian = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable obsidian";
    };
  };

  config = lib.mkIf config.planet.programs.obsidian.enable {
    environment.systemPackages = [ pkgs-unstable.obsidian ];
  };
}
