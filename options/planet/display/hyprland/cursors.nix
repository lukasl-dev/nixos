{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;

  cursorPackage = pkgs.catppuccin-cursors.mochaLight;
  cursorName = "Catppuccin-Mocha-Light-Cursors";
  cursorSize = 26;
in
{
  config = lib.mkIf hyprland.enable {
    environment.systemPackages = [ cursorPackage ];

    environment.sessionVariables = {
      XCURSOR_THEME = cursorName;
      XCURSOR_SIZE = toString cursorSize;
      HYPRCURSOR_THEME = cursorName;
      HYPRCURSOR_SIZE = toString cursorSize;
    };

    planet.hm = [
      {
        home.pointerCursor = {
          gtk.enable = true;
          package = cursorPackage;
          name = cursorName;
          size = cursorSize;
        };
      }
    ];
  };
}
