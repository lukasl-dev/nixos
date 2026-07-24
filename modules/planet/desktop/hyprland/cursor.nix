{
  atlas,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) catppuccin planet;
  inherit (pkgs.stdenv.hostPlatform) system;

  cursorPackage = pkgs.catppuccin-cursors.${catppuccin.flavor + "Light"};
  cursorName = "catppuccin-${catppuccin.flavor}-light-cursors";
  cursorSize = 26;

  hyprctl = lib.getExe' inputs.hyprland.packages.${system}.hyprland "hyprctl";
in
{
  config = lib.mkIf planet.desktop.enable {
    environment = {
      systemPackages = [ cursorPackage ];

      sessionVariables = {
        XCURSOR_THEME = cursorName;
        XCURSOR_SIZE = toString cursorSize;
        HYPRCURSOR_THEME = cursorName;
        HYPRCURSOR_SIZE = toString cursorSize;
      };
    };

    planet.desktop.hyprland.autoStart = [
      "${hyprctl} setcursor ${cursorName} ${toString cursorSize}"
    ];

    hjem.users = atlas.travellers.forEach planet (_: {
      rum.misc.gtk = {
        packages = [ cursorPackage ];
        settings = {
          cursor-theme-name = cursorName;
          cursor-theme-size = cursorSize;
        };
      };
    });
  };
}
