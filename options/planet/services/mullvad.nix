{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  inherit (config.planet) wm;

  inherit (config.planet.services) mullvad;
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

    # Re-apply LAN allow on boot / daemon restart
    systemd.services.mullvad-tailscale-compat = {
      description = "Mullvad settings for Tailscale compatibility";
      wantedBy = [ "multi-user.target" ];
      after = [ "mullvad-daemon.service" ];
      requires = [ "mullvad-daemon.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        set -euo pipefail
        mullvad lan set allow || true
      '';
    };

    # Ensure tailscaled is always excluded via split tunnel, even after restarts
    systemd.services.tailscaled.serviceConfig.ExecStartPost = [
      "-mullvad split-tunnel add $MAINPID"
    ];
  };
}
