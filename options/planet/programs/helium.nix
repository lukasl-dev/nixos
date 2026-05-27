{
  jail,
  self,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) helium;
  inherit (pkgs.stdenv.hostPlatform) system;

  unwrapped = self.packages.${system}.helium;

  features = lib.optionalString (display.type == "wayland") "WaylandLinuxDrmSyncobj";

  wrapped = pkgs.symlinkJoin {
    name = "helium";
    paths = [ unwrapped ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -f $out/bin/helium
      makeWrapper ${lib.getExe unwrapped} $out/bin/helium \
        --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath unwrapped.runtimeLibs}" \
        --add-flags "--ozone-platform=${toString display.type}" \
        ${lib.optionalString (features != "") ''--add-flags "--enable-features=${features}"''}
    '';
    inherit (unwrapped) meta;
  };

  jailed = jail "helium" wrapped (
    with jail.combinators;
    [
      network
      gui
      gpu
      (tmpfs "/dev/shm")
      # Chromium's profile singleton socket lives below /tmp.  If each jail gets
      # a private /tmp, a second `helium` invocation cannot talk to the already
      # running instance and the shared profile opens half-broken.
      (add-runtime "mkdir -p ~/.local/share/jail.nix/tmp/helium")
      (rw-bind (noescape "~/.local/share/jail.nix/tmp/helium") "/tmp")
      (persist-home "helium")
      (add-runtime "mkdir -p ~/Downloads")
      (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
      (unsafe-add-raw-args ''--bind-try "$XDG_RUNTIME_DIR/doc" "$XDG_RUNTIME_DIR/doc"'')
      camera
      notifications
      (add-pkg-deps [ pkgs.xdg-utils ])
      (add-runtime ''
        for dev in /dev/nvidia*; do
          [ -e "$dev" ] || continue
          RUNTIME_ARGS+=(--dev-bind "$dev" "$dev")
        done
      '')
      (wrap-entry (_: ''
        exec ${lib.getExe' wrapped "helium"} \
          --no-sandbox \
          --disable-gpu-sandbox \
          "$@"
      ''))
      (dbus {
        talk = [
          "org.freedesktop.portal.*"
          "org.freedesktop.Notifications"
          "org.freedesktop.secrets"
          "org.mpris.*"
        ];
      })
    ]
  );
in
{
  options.planet.programs = {
    helium = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable helium browser";
      };

      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default = pkgs.symlinkJoin {
          name = "helium";
          paths = [
            jailed
            wrapped
          ];
          inherit (unwrapped) meta;
        };
        description = "Package used for Helium browser.";
        example = "jail \"helium\" (pkgs.symlinkJoin { ... }) [...];";
      };
    };
  };

  config = lib.mkIf helium.enable {
    environment.systemPackages = [ helium.package ];

    planet.display.hyprland.lua =
      let
        exe = lib.getExe' helium.package "helium";
      in
      [
        # lua
        ''
          hl.bind("SUPER + B", hl.dsp.exec_cmd("${exe}"))
        ''
      ];
  };
}
