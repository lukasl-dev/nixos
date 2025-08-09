{
  config,
  lib,
  pkgs,
  ...
}:

let
  wm = config.planet.wm;
  hyprland = wm.hyprland;
in
{
  options.planet.programs.rofi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable rofi";
    };
  };

  config = lib.mkIf config.planet.programs.rofi.enable {
    universe.hm = [
      {
        programs.rofi = {
          enable = true;
          package = lib.mkIf hyprland.enable pkgs.rofi-wayland;
          theme = ./theme.rasi;
        };

        catppuccin.rofi.enable = false;

        home.packages = [ pkgs.bemoji ];
      }
    ];
  };
}
