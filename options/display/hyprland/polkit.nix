{ config, lib, ... }:

let
  inherit (config.planet.display) hyprland;
in
{
  config = lib.mkIf hyprland.enable {
    security.polkit.enable = true;

    planet.display.hyprland.on.start = [
      # lua
      ''hl.exec_cmd("systemctl --user start hyprpolkitagent")''

      # https://discourse.nixos.org/t/keyctl-read-alloc-permission-denied/8667/4
      # lua
      ''hl.exec_cmd("keyctl link @u @s")''
    ];
  };
}
