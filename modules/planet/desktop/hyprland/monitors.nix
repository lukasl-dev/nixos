{ config, lib, ... }:

let
  inherit (config) planet;
  inherit (planet.desktop) hyprland;

  toLua = lib.generators.toLua { };

  render =
    output: monitor: # lua
    ''
      hl.monitor({
        output = ${toLua output},
        mode = ${toLua monitor.mode},
        position = ${toLua monitor.position},
        scale = ${toLua monitor.scale},
      })
    '';
in
{
  options.planet.desktop.hyprland.monitors = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          mode = lib.mkOption {
            type = lib.types.str;
            example = "1920x1080@144";
            description = "Monitor mode and refresh rate.";
          };

          position = lib.mkOption {
            type = lib.types.str;
            example = "0x0";
            description = "Monitor position.";
          };

          scale = lib.mkOption {
            type = lib.types.number;
            example = 1;
            description = "Monitor scale factor.";
          };
        };
      }
    );
    default = { };
    example = {
      "DP-1" = {
        mode = "1920x1080@144";
        position = "0x0";
        scale = 1;
      };
    };
    description = "Hyprland monitors keyed by output name.";
  };

  config = lib.mkIf planet.desktop.enable {
    planet.desktop.hyprland.lua = lib.concatStringsSep "\n" (
      lib.mapAttrsToList render hyprland.monitors
      ++ [ ''hl.monitor({ output = "Unknown-1", disabled = true })'' ]
    );
  };
}
