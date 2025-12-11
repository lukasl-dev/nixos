{ config, lib, ... }:

let
  inherit (config.planet.wm) hyprland;
in
{
  config = lib.mkIf hyprland.enable {
    universe.hm = [
      {
        wayland.windowManager.hyprland.settings = {
          exec-once = lib.mkAfter [
            # TODO: replace with services.hyprpolkitagent.enable = true;
            "systemctl --user start hyprpolkitagent"

            # https://discourse.nixos.org/t/keyctl-read-alloc-permission-denied/8667/4
            "keyctl link @u @s"
          ];
        };
      }
    ];
  };
}
