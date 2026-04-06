{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "vega-mic1-volume";
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
              pw-cli s "$source_id" Props '{ volume: 1.35, channelVolumes: [ 1.35 ], softVolumes: [ 1.35 ] }'
              exit 0
            fi

            sleep 1
          done

          echo "vega-mic1-volume: could not find Mic1 source" >&2
          exit 1
        '';
    })
  ];

  planet.wm.hyprland.launch = [ "vega-mic1-volume" ];
}
