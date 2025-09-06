{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  wm = config.planet.wm;

  mullvad = config.planet.services.mullvad;
in
{
  options.planet.services.mullvad = {
    enable = lib.mkEnableOption "Enable mullvad vpn";
  };

  config = lib.mkIf mullvad.enable {
    services.mullvad-vpn = {
      enable = true;
      package = lib.mkIf wm.enable pkgs-unstable.mullvad-vpn;
    };

    environment.systemPackages = [
      pkgs-unstable.mullvad-vpn
      (lib.mkIf wm.enable pkgs-unstable.mullvad-browser)
    ];

    # systemd.services.mullvad-allow-lan = {
    #   description = "Allow LAN traffic with Mullvad";
    #   wantedBy = [ "multi-user.target" ];
    #   after = [ "mullvad-daemon.service" ];
    #   serviceConfig = {
    #     Type = "oneshot";
    #   };
    #   script = ''
    #     ${lib.getExe pkgs-unstable.mullvad-vpn} lan set allow || true
    #   '';
    # };
  };
}
