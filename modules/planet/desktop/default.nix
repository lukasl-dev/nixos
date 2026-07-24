{ lib, ... }:

{
  imports = [
    ./fonts.nix
    ./gtk.nix
    ./hyprland
    ./qt.nix
    ./xdg.nix
  ];

  options.planet.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
}
