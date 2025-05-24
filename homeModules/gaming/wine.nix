{
  config,
  lib,
  pkgs,
  ...
}:

let
  wayland = config.wayland.windowManager.hyprland.enable;
in
{
  home.packages = [
    pkgs.winetricks

    (lib.mkIf wayland pkgs.wineWowPackages.waylandFull)
  ];
}
