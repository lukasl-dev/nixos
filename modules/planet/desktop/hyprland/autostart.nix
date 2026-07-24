{ config, lib, ... }:

let
  inherit (config) planet;
  inherit (planet) desktop;

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
  config = lib.mkIf (desktop.enable && desktop.autoStart != [ ]) {
    planet.desktop.hyprland.lua = render desktop.autoStart;
  };
}
