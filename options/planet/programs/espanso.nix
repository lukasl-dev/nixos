{ config, lib, ... }:

let
  wm = config.planet.wm;
  hyprland = wm.hyprland;
in
{
  options.planet.programs.espanso = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable espanso";
    };
  };

  config = lib.mkIf config.planet.programs.espanso.enable {
    universe.hm = [
      {
        services.espanso = {
          enable = true;
          waylandSupport = hyprland.enable;
        };
      }
    ];
  };
}
