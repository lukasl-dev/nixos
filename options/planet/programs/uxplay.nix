{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.programs) uxplay;
in
{
  options.planet.programs = {
    uxplay = {
      enable = lib.mkEnableOption "Enable UxPlay";
    };
  };

  config = lib.mkIf uxplay.enable {
    assertions = [
      {
        assertion = config.planet.networking.dns.discoverable;
        message = "UxPlay requires planet.networking.dns.discoverable to be true for device discovery";
      }
    ];

    networking.firewall = {
      allowedTCPPorts = [
        4000
        4001
        4002
      ];
      allowedUDPPorts = [
        5000
        5001
        5002
      ];
    };

    environment.systemPackages = [
      (pkgs.unstable.writeShellApplication {
        name = "uxplay";
        runtimeInputs = [ pkgs.unstable.uxplay ];
        text = ''
          PID_FILE="/tmp/uxplay.pid"
          if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
              kill "$(cat "$PID_FILE")"
              rm "$PID_FILE"
          else
              ${lib.getExe pkgs.unstable.uxplay} -p tcp 4000 -p udp 5000 &> /dev/null & echo $! > "$PID_FILE"
          fi
        '';
      })

    ];
  };
}
