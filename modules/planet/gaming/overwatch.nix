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

          -- Prevent Overwatch/XWayland from changing Hyprland's
          -- fullscreen or maximised window state.
          suppress_event = "fullscreen maximize fullscreenoutput",
        })
      '';
  };
}
