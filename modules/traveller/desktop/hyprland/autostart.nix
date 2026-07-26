{ config, lib, ... }:

let
  inherit (config.traveller.desktop) hyprland;

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
  options.traveller.desktop.hyprland.autoStart = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [
      "firefox"
      "vesktop"
    ];
    description = "Traveller commands to execute when Hyprland starts.";
  };

  config = lib.mkIf (hyprland.autoStart != [ ]) {
    traveller.desktop.hyprland.lua = render hyprland.autoStart;
  };
}
