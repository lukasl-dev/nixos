{
  config,
  lib,
  ...
}:

let
  inherit (config) planet;
in
{
  config = lib.mkIf planet.gaming.enable {
    planet.desktop.hyprland.lua = # lua
      ''
        hl.window_rule({
          match = {
            class = "^steam_app_2357570$",
          },

          fullscreen = true,
          confine_pointer = true,
          focus_on_activate = true,

          -- Ignore fullscreen state changes requested by Overwatch itself.
          suppress_event = "fullscreen maximize fullscreenoutput",
        })
      '';
  };
}
