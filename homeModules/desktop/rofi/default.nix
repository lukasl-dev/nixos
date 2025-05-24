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
  programs.rofi = {
    enable = true;
    package = lib.mkIf wayland pkgs.rofi-wayland;
    theme = ./theme.rasi;
  };

  catppuccin.rofi.enable = false;

  home.packages = [
    pkgs.bemoji
  ];
}
