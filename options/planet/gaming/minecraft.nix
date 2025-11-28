{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  hyprland = config.planet.wm.hyprland;

  minecraft = config.planet.gaming.minecraft;
in
{
  options.planet.gaming.minecraft = {
    enable = lib.mkEnableOption "Enable minecraft";
  };

  config = lib.mkIf minecraft.enable {
    environment.systemPackages = [
      pkgs-unstable.prismlauncher
      pkgs-unstable.lunar-client

      (lib.mkIf hyprland.enable pkgs-unstable.glfw3-minecraft)
    ];
  };

  # prismlauncher settings:
  # __GL_THREADED_OPTIMIZATIONS=0
  # use glfw
}
