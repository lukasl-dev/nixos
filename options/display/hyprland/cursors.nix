{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
in
{
  config = lib.mkIf hyprland.enable {
    planet.hm = [
      {
        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.catppuccin-cursors.mochaLight;
          name = "Catppuccin-Mocha-Light-Cursors";
          size = 26;
        };
      }
    ];
  };
}
