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
  inherit (planet.desktop.hyprland) cursor;
  inherit (pkgs.stdenv.hostPlatform) system;

  hyprctl = lib.getExe' inputs.hyprland.packages.${system}.hyprland "hyprctl";
in
{
  options.planet.desktop.hyprland.cursor = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.catppuccin-cursors.${catppuccin.flavor + "Light"};
      readOnly = true;
      internal = true;
      description = "Cursor theme package.";
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-${catppuccin.flavor}-light-cursors";
      readOnly = true;
      internal = true;
      description = "Cursor theme name.";
    };

    size = lib.mkOption {
      type = lib.types.ints.positive;
      default = 26;
      readOnly = true;
      internal = true;
      description = "Cursor size.";
    };
  };

  config = lib.mkIf planet.desktop.enable {
    environment = {
      systemPackages = [ cursor.package ];

      sessionVariables = {
        XCURSOR_THEME = cursor.name;
        XCURSOR_SIZE = toString cursor.size;
        HYPRCURSOR_THEME = cursor.name;
        HYPRCURSOR_SIZE = toString cursor.size;
      };
    };

    planet.desktop.hyprland.autoStart = [
      "${hyprctl} setcursor ${cursor.name} ${toString cursor.size}"
    ];

    hjem.users = atlas.travellers.forEach planet (_: {
      rum.misc.gtk = {
        packages = [ cursor.package ];
        settings = {
          cursor-theme-name = cursor.name;
          cursor-theme-size = cursor.size;
        };
      };
    });
  };
}
