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
  options.planet.gaming.steam.enable = lib.mkEnableOption "Steam";

  config = lib.mkIf planet.gaming.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };
}
