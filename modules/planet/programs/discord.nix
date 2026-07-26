{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) discord;
in
{
  options.planet.programs.discord.enable = lib.mkEnableOption "Discord" // {
    default = planet.desktop.enable;
    defaultText = lib.literalExpression "config.planet.desktop.enable";
  };

  config = lib.mkIf discord.enable {
    environment.systemPackages = [ pkgs.vesktop ];
  };
}
