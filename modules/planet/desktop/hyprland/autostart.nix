{ config, lib, ... }:

let
  inherit (config) planet;
  inherit (planet.desktop) hyprland;

  toLua = lib.generators.toLua { };

  render =
    commands: # lua
    ''
      hl.on("hyprland.start", function()
      ${lib.concatMapStringsSep "\n" (
        command: "  hl.exec_cmd(${toLua command})"
      ) commands}
      end)
    '';
in
{
  options.planet.desktop.hyprland.autoStart = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [
      "firefox"
      "vesktop"
    ];
    description = "Planet commands to execute when Hyprland starts.";
  };

  config = lib.mkIf (planet.desktop.enable && hyprland.autoStart != [ ]) {
    planet.desktop.hyprland.lua = render hyprland.autoStart;
  };
}
