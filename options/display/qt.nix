{ config, lib, ... }:

lib.mkIf config.planet.display.enable {
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
