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
        MULLVAD=${lib.getExe pkgs-unstable.mullvad-vpn}

        $MULLVAD lan set allow || true

        if $MULLVAD help 2>&1 | grep -q "split-tunnel"; then
          $MULLVAD split-tunnel add by-app /run/current-system/sw/bin/tailscaled || true
        fi
      '';
    };
  };
}
