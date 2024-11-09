{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lutris
    protonup-qt
    wineWowPackages.waylandFull

    prismlauncher
    glfw-wayland-minecraft

    gamemode
    gamescope
    gamescope-wsi
  ];
}
