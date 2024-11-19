{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lutris
    protonup-qt
    wineWowPackages.waylandFull

    bottles

    prismlauncher
    glfw-wayland-minecraft
    lunar-client

    gamemode
    gamescope
    gamescope-wsi
  ];
}
