{
  pkgs,
  pkgs-unstable,
  ...
}:

{
  home.packages = [
    # wine
    pkgs.lutris
    pkgs.protonup-qt
    pkgs.bottles
    pkgs.wineWowPackages.waylandFull
    pkgs.winetricks

    # performance
    pkgs.gamescope
    pkgs.gamescope-wsi

    # minecraft
    pkgs-unstable.prismlauncher
    pkgs-unstable.glfw-wayland-minecraft
    pkgs-unstable.lunar-client

    pkgs-unstable.r2modman

    pkgs.furmark
  ];

  # prismlauncher settings:
  # __GL_THREADED_OPTIMIZATIONS=0
  # use glfw
}
