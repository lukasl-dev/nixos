{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
in
{
  options.planet.gaming.minecraft.enable = lib.mkEnableOption "Minecraft launchers";

  config = lib.mkIf planet.gaming.minecraft.enable {
    environment.systemPackages = with pkgs; [
      glfw3-minecraft
      lunar-client
      prismlauncher
    ];
  };
}
