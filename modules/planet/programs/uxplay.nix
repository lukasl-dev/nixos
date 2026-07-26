{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) uxplay;

  executable = lib.getExe pkgs.uxplay;

  toggle = pkgs.writeShellApplication {
    name = "uxplay";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      runtime_dir="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}}"
      pid_file="$runtime_dir/uxplay-$UID.pid"

      if [[ -r "$pid_file" ]]; then
        read -r pid < "$pid_file"

        if [[ "$pid" =~ ^[0-9]+$ ]] \
          && kill -0 "$pid" 2>/dev/null \
          && [[ "$(readlink -f "/proc/$pid/exe")" == ${lib.escapeShellArg executable} ]]; then
          kill "$pid"
          rm -f "$pid_file"
          echo "UxPlay stopped."
          exit 0
        fi

        rm -f "$pid_file"
      fi

      ${executable} -p tcp 4000 -p udp 5000 >/dev/null 2>&1 &
      printf '%s\n' "$!" > "$pid_file"
      echo "UxPlay started."
    '';
  };
in
{
  options.planet.programs.uxplay.enable = lib.mkEnableOption "UxPlay AirPlay mirroring";

  config = lib.mkIf uxplay.enable {
    assertions = [
      {
        assertion = planet.networking.dns.discoverable;
        message = ''
          UxPlay requires planet.networking.dns.discoverable to be true for
          device discovery.
        '';
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

    environment.systemPackages = [ toggle ];
  };
}
