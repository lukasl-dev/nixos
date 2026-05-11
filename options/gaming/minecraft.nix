{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
  inherit (config.planet.gaming) minecraft;
in
{
  options.planet.gaming = {
    minecraft = {
      enable = lib.mkEnableOption "Enable minecraft";
    };
  };

  config = lib.mkIf minecraft.enable {
    environment.systemPackages = [
      pkgs.unstable.prismlauncher
      pkgs.unstable.lunar-client

      (lib.mkIf hyprland.enable pkgs.unstable.glfw3-minecraft)
    ];
  };

  # prismlauncher settings:
  # __GL_THREADED_OPTIMIZATIONS=0
  # use glfw
}
