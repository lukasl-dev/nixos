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

    autoStart = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "firefox"
        "vesktop"
      ];
      description = "Planet commands to execute when the desktop starts.";
    };
  };
}
