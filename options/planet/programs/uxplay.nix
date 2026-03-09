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
  options.planet.programs.uxplay = {
    enable = lib.mkEnableOption "Enable UxPlay";
  };

  config = lib.mkIf uxplay.enable {
    assertions = [
      {
        assertion = config.planet.networking.dns.discoverable;
        message = "UxPlay requires planet.networking.dns.discoverable to be true for device discovery";
      }
    ];

    environment.systemPackages = [
      pkgs.unstable.uxplay
      (pkgs.unstable.writeShellApplication {
        name = "uxplay-toggle";
        runtimeInputs = [ pkgs.unstable.uxplay ];
        text = ''
          PID_FILE="/tmp/uxplay.pid"
          if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
              kill "$(cat "$PID_FILE")"
              rm "$PID_FILE"
          else
              sudo nixos-firewall-tool open tcp 4000
              sudo nixos-firewall-tool open tcp 4001
              sudo nixos-firewall-tool open tcp 4002
              sudo nixos-firewall-tool open udp 5000
              sudo nixos-firewall-tool open udp 5001
              sudo nixos-firewall-tool open udp 5002
              uxplay -p tcp 4000 -p udp 5000 &> /dev/null & echo $! > "$PID_FILE"
          fi
        '';
      })

    ];
  };
}
