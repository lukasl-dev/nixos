{ config, lib, ... }:

{
  config = lib.mkIf config.planet.desktop.enable {
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
  };
}
