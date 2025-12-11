{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (config.planet.wm) hyprland;

  inherit (config.planet.programs) element;

  package = pkgs-unstable.element-desktop;
in
{
  options.planet.programs.element = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable element";
      example = "true";
    };
  };

  config = lib.mkIf element.enable {
    universe.hm = [
      {
        programs.element-desktop = {
          enable = true;
          inherit package;
        };

        wayland.windowManager.hyprland.settings = {
          exec-once = lib.mkAfter [ (lib.getExe package) ];
          windowrulev2 = lib.mkIf hyprland.enable (
            let
              selector = "initialClass:(Element)";
            in
            lib.mkAfter [
              "renderunfocused, ${selector}"
              "workspace 1, ${selector}"
              "noinitialfocus, ${selector}"
            ]
          );
        };
      }
    ];
  };
}
