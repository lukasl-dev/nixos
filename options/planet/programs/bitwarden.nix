{
  jail,
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) bitwarden;

  jailed = jail "bitwarden" pkgs.unstable.bitwarden-desktop (
    with jail.combinators;
    [
      network
      gui
      gpu
      (persist-home "bitwarden")
      (readwrite "/run/dbus")
      (add-pkg-deps [ pkgs.xdg-utils ])
      (add-runtime ''
        for dev in /dev/nvidia*; do
          [ -e "$dev" ] || continue
          RUNTIME_ARGS+=(--dev-bind "$dev" "$dev")
        done
      '')
      notifications
      (dbus {
        talk = [
          "org.freedesktop.Notifications"
          "org.freedesktop.secrets"
          "org.kde.StatusNotifierItem.*"
        ];
      })
    ]
  );
in
{
  options.planet.programs = {
    bitwarden = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable bitwarden";
        example = "true";
      };

      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default = pkgs.symlinkJoin {
          name = "bitwarden";
          paths = [ jailed pkgs.unstable.bitwarden-desktop ];
        };
        description = "Package used for Bitwarden.";
        example = "pkgs.unstable.bitwarden-desktop";
      };

      launch = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = lib.getExe' bitwarden.package "bitwarden";
        description = "Command used to launch Bitwarden.";
        example = "bitwarden";
      };
    };
  };

  config = lib.mkIf bitwarden.enable {
    planet.display.hyprland.autoStart = [ bitwarden.launch ];

    environment.systemPackages = [
      bitwarden.package
      pkgs.unstable.bitwarden-cli
    ];
  };
}
