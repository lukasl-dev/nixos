{ config, lib, ... }:

let
  inherit (config.planet.wm) hyprland;

  # binding =
  #   key: action: params:
  #   "${hyprland.mod}, ${key}, ${action}, ${params}";

  binding =
    {
      key,
      action,
      params,
    }:
    "${hyprland.mod}, ${key}, ${action}, ${params}";
in
{
  options.wm.hyprland.bindings = lib.types.listOf lib.types.submodule {
    options = {
      key = lib.mkOption {
        type = lib.types.str;
        description = "Key trigger";
        default = "";
        example = "Space";
      };

      action = lib.mkOption {
        type = lib.types.str;
        description = "Hyprland action to perform";
        default = "exec";
        example = "exec";
      };

      params = lib.mkOption {
        type = lib.types.str;
        description = "Parameters to be passed to Hyprland action";
        default = "";
        example = "rofi";
      };
    };
  };

  config = lib.mkIf hyprland.enable {
    universe.hm = [
      {
        wayland.windowManager.hyprland.settings = {
          bind = lib.mkAfter [
            (binding {
              key = "Space";
              action = "exec";
              params = "caelestia shell drawers toggle launcher";
            })
            (binding {
              key = "Backspace";
              action = "exec";
              params = "caelestia shell drawers toggle launcher";
            })

            (binding {
              key = "C";
              action = "exec";
              params = "caelestia clipboard";
            })

            (binding {
              key = "C";
              action = "exec";
              params = "caelestia clipboard";
            })
          ];
        };
      }
    ];
  };
}
