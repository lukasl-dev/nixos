{ pkgs, config, ... }:

{
  imports = [
    ./desktop-entries.nix
    ./mime-apps.nix
  ];

  xdg = {
    enable = true;

    cacheHome = config.home.homeDirectory + "/.local/cache";
    configHome = config.home.homeDirectory + "/.config";

    userDirs = {
      enable = true; createDirectories = true;
    };

    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common.default = [ "gtk" ];
        hyprland.default = [
          "gtk"
          "hyprland"
        ];
      };
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };
  };  
}
