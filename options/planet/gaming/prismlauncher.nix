{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  hyprland = config.planet.wm.hyprland;

  prismlauncher = config.planet.gaming.prismlauncher;
in
{
  options.planet.gaming.prismlauncher = {
    enable = lib.mkEnableOption "Enable prismlauncher";
  };

  config = lib.mkIf prismlauncher.enable {
    environment.systemPackages = [
      pkgs-unstable.prismlauncher
      pkgs-unstable.lunar-client

      (lib.mkIf hyprland.enable pkgs-unstable.glfw-wayland-minecraft)
    ];
  };

  # prismlauncher settings:
  # __GL_THREADED_OPTIMIZATIONS=0
  # use glfw
}
