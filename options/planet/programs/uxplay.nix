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
              uxplay -p tcp 4000 -p udp 5000 &> /dev/null & echo $! > "$PID_FILE"
          fi
        '';
      })

    ];

    networking.firewall = {
      allowedTCPPorts = [
        7000
        7100

        4000
        4001
        4002
      ];

      allowedUDPPorts = [
        5000
        5001
        5002

        6000
        6001
        7011
        5353
      ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  };
}
