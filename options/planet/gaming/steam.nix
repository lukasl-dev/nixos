{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  steam = config.planet.gaming.steam;
in
{
  options.planet.gaming.steam = {
    enable = lib.mkEnableOption "Enable steam";
  };

  config = lib.mkIf steam.enable {
    programs.steam = {
      enable = true;

      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;

      extraCompatPackages = [ pkgs-unstable.proton-ge-bin ];
    };
  };
}
