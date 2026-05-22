{ pkgs, lib, ... }:

let
  script = pkgs.writeShellApplication {
    name = "vega-fix-audio-volume";
    runtimeInputs = [
      pkgs.wireplumber
      pkgs.pipewire
      pkgs.gnugrep
      pkgs.gnused
      pkgs.coreutils
    ];
    text = # bash
      ''
        set -eu

        for _ in $(seq 1 20); do
          source_id="$(wpctl status -n \
            | grep 'HiFi__Mic1__source' \
            | head -n1 \
            | sed -E 's/^[^0-9]*([0-9]+)\..*/\1/')"

          if [ -n "$source_id" ]; then
            wpctl set-default "$source_id"
            pw-cli s "$source_id" Props '{ volume: 1.8, channelVolumes: [ 1.8 ], softVolumes: [ 1.8 ] }'
            exit 0
          fi

          sleep 1
        done

        echo "could not find Mic1 source" >&2
        exit 1
      '';
  };
in
{
  environment.systemPackages = [ script ];

  systemd.user.services.vega-fix-audio-volume = {
    description = "Set Scarlett Mic1 as default source with boosted volume";
    after = [
      "graphical-session.target"
      "pipewire.service"
      "wireplumber.service"
    ];
    wants = [
      "graphical-session.target"
      "pipewire.service"
      "wireplumber.service"
    ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe script;
    };
    wantedBy = [ "graphical-session.target" ];
  };
}
