{ config, lib, ... }:

lib.mkIf config.planet.wm.enable {
  universe.hm = [
    {
      gtk = {
        enable = true;

        gtk3 = {
          extraConfig = {
            gtk-application-prefer-dark-theme = 1;
            gtk-error-bell = 0;
          };
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
          gtk-error-bell = 0;
        };
      };
    }
  ];
}
