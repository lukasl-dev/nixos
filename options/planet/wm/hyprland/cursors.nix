{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  inherit (config.planet.wm) hyprland;
in
{
  config = lib.mkIf hyprland.enable {
    environment.systemPackages = with pkgs-unstable; [
      hyprcursor
      catppuccin-cursors.mochaMauve
    ];

    universe.hm = [
      {
        wayland.windowManager.hyprland.settings = {
          env = lib.mkAfter [
            "HYPRCURSOR_SIZE,26"
            "HYPRCURSOR_THEME,Catppuccin-Mocha-Light-Cursors"
          ];
        };
      }
    ];
  };
}
