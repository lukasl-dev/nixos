{
  config,
  lib,
  pkgs,
  ...
}:

let
  hyprland = config.planet.wm.hyprland;
in
{
  environment.systemPackages = [
    pkgs.winetricks
    (lib.mkIf hyprland.enable pkgs.wineWowPackages.waylandFull)
  ];
}
