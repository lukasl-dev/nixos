{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.planet.networking.vpn.tu;
in
{
  options.planet.networking.vpn.tu = {
    enable = lib.mkEnableOption "TU Vienna VPN (OpenConnect)";
    group = lib.mkOption {
      type = lib.types.enum [
        "1_TU_getunnelt"
        "2_Alles_getunnelt"
      ];
      default = "1_TU_getunnelt";
      description = "1_TU_getunnelt for split tunnel (recommended), 2_Alles_getunnelt for full tunnel.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.openconnect
      (pkgs.writeShellScriptBin "tuvpn" ''
        case "''${1:-}" in
          start|up)
            exec sudo systemctl start vpn-tu
            ;;
          stop|down)
            exec sudo systemctl stop vpn-tu
            ;;
          status|"")
            exec systemctl status vpn-tu
            ;;
          list|sessions)
            url="https://nix.kom.tuwien.ac.at/vpn-sessions"
            if [ -n "''${DISPLAY:-}''${WAYLAND_DISPLAY:-}" ]; then
              exec ${pkgs.xdg-utils}/bin/xdg-open "$url"
            else
              echo "$url"
            fi
            ;;
          *)
            echo "Usage: tuvpn [start|stop|status|list]"
            exit 1
            ;;
        esac
      '')
    ];

    sops.secrets = {
      "universe/vpn/tu_vienna/username" = { };
      "universe/vpn/tu_vienna/password" = { };
    };

    systemd.services.vpn-tu = {
      description = "TU Vienna VPN";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "tuvpn-connect" ''
          ${pkgs.openconnect}/bin/openconnect \
            --user="$(cat ${config.sops.secrets."universe/vpn/tu_vienna/username".path})" \
            --authgroup="${cfg.group}" \
            --passwd-on-stdin \
            vpn.tuwien.ac.at \
            < ${config.sops.secrets."universe/vpn/tu_vienna/password".path}
        '';
      };
    };
  };
}
