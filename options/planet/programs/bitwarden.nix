{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (config.planet.wm) hyprland;

  inherit (config.planet.programs) bitwarden;

  package-desktop = pkgs-unstable.bitwarden-desktop;
in
{
  options.planet.programs.bitwarden = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable bitwarden";
      example = "true";
    };
  };

  config = lib.mkIf bitwarden.enable {
    environment.systemPackages = [
      package-desktop
      pkgs-unstable.bitwarden-cli
    ];

    universe.hm = [
      {
        wayland.windowManager.hyprland.settings = lib.mkIf hyprland.enable {
          exec-once = lib.mkAfter [ (lib.getExe package-desktop) ];
          windowrulev2 =
            let
              selector = "title:(Bitwarden)";
            in
            lib.mkAfter [
              "float, ${selector}"
              "center, ${selector}"
              "opacity 0.8, ${selector}"
              "size 1309 783, ${selector}"
            ];
        };
      }
    ];
  };
}
