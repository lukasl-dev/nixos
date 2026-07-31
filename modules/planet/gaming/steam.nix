{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.networking) mullvad;

  basePackage = pkgs.steam;

  excludedPackage = basePackage.override (previous: {
    extraPreBwrapCmds = ''
      ${previous.extraPreBwrapCmds or ""}

      if [[ -z "''${PLANET_MULLVAD_EXCLUDED:-}" ]]; then
        export PLANET_MULLVAD_EXCLUDED=1
        exec ${config.security.wrapperDir}/mullvad-exclude \
          "$0" "$@"
      fi
    '';
  });
in
{
  options.planet.gaming.steam.enable = lib.mkEnableOption "Steam";

  config = lib.mkIf planet.gaming.steam.enable {
    programs.steam = {
      enable = true;
      package = if mullvad.enable then excludedPackage else basePackage;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };
}
