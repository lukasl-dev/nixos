{
  config,
  lib,
  pkgs,
  ...
}:

let
  hyprland = config.wayland.windowManager.hyprland.enable;
in
{
  wayland.windowManager.hyprland.settings.env = lib.mkIf hyprland [
    "HYPRCURSOR_SIZE,26"
    "HYPRCURSOR_THEME,Catppuccin-Mocha-Light-Cursors"
  ];

  home.file.".icons" = {
    enable = true;
    source = "${pkgs.catppuccin-cursors.mochaLight}/share/icons/";
    target = ".icons";
  };
}
