{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lutris
    protonup-qt

    wineWowPackages.waylandFull
    # (wine.override { wineBuild = "wine64"; })
    winetricks

    bottles

    prismlauncher
    glfw-wayland-minecraft
    lunar-client

    gamemode
    gamescope
    gamescope-wsi
  ];
}
