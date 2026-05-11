{
  config,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
in
{
  options.planet.display.hyprland = {
    monitors = lib.mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = {
            output = lib.mkOption {
              type = str;
              description = "Monitor output name.";
              example = "DP-1";
            };
            mode = lib.mkOption {
              type = str;
              description = "Monitor mode and refresh rate.";
              example = "1920x1080@144";
            };
            position = lib.mkOption {
              type = str;
              description = "Monitor position.";
              example = "0x0";
            };
            scale = lib.mkOption {
              type = number;
              description = "Monitor scale factor.";
              example = 1;
            };
          };
        });
      default = [ ];
      example = [
        {
          output = "DP-1";
          mode = "1920x1080@144";
          position = "0x0";
          scale = 1;
        }
      ];
      description = "List of Hyprland monitors.";
    };
  };

  config = lib.mkIf hyprland.enable {
    planet.display.hyprland.lua =
      let
        toLua = lib.generators.toLua { };

        monitorToLua =
          monitor: # lua
          ''
            hl.monitor({
              output = ${toLua monitor.output},
              mode = ${toLua monitor.mode},
              position = ${toLua monitor.position},
              scale = ${toLua monitor.scale},
            })
          '';
      in
      map monitorToLua hyprland.monitors;
  };
}
