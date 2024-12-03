{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # wine
    lutris
    protonup-qt
    bottles
    wineWowPackages.waylandFull
    winetricks

    # minecraft
    prismlauncher
    glfw-wayland-minecraft
    lunar-client

    # performance
    gamemode
    gamescope
    gamescope-wsi
  ];
}
