{ config, lib, ... }:

let
  inherit (config.planet) display;
in
{
  imports = [
    ./hyprland

    ./gtk.nix
    ./qt.nix
    ./sddm.nix
  ];

  options.planet = {
    display = {
      enable = lib.mkEnableOption "Enable display server";

      type = lib.mkOption {
        type = lib.types.enum [
          "wayland"
          "x11"
        ];
        readOnly = true;
        default = if display.hyprland.enable then "wayland" else "x11";
        description = "Display protocol";
      };
    };
  };
}
