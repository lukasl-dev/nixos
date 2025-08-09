{ config, lib, ... }:

lib.mkIf config.planet.wm.enable {
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
