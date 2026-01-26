{
  pkgs,
  config,
  lib,
  ...
}:

let
  steam = config.planet.gaming.steam;
  mullvad = config.planet.services.mullvad;
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

      extraCompatPackages = [ pkgs.unstable.proton-ge-bin ];
    };

    universe.hm = lib.optionals mullvad.enable (
      let
        baseDesktop = builtins.readFile "${pkgs.unstable.steam-unwrapped}/share/applications/steam.desktop";
        vpnDesktop =
          lib.replaceStrings
            [ "Name=Steam\n" "Exec=steam %U\n" ]
            [ "Name=Steam (VPN-Bypass)\n" "Exec=mullvad-exclude steam %U\n" ]
            baseDesktop;
      in
      [
        {
          home.file."steam-vpn-bypass.desktop" = {
            target = ".local/share/applications/steam-vpn-bypass.desktop";
            text = vpnDesktop;
          };
        }
      ]
    );
  };
}
