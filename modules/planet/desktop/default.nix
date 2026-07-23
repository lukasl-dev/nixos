{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./fonts.nix
    ./xdg.nix
  ];

  options.planet.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.planet.desktop.enable {
    # TODO: delete once hyprland is set up
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };
  };
}
