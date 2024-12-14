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

  # prismlauncher settings:
  # __GL_THREADED_OPTIMIZATIONS=0
  # use glfw
}
