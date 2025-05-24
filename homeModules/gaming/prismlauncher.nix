{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  wayland = config.wayland.windowManager.hyprland.enable;
in
{
  home.packages = [
    pkgs-unstable.prismlauncher
    pkgs-unstable.lunar-client

    (lib.mkIf wayland pkgs-unstable.glfw-wayland-minecraft)
  ];

  # prismlauncher settings:
  # __GL_THREADED_OPTIMIZATIONS=0
  # use glfw
}
