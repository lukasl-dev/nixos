{ config, lib, ... }:

let
  inherit (config.universe) user;
in
lib.mkIf config.planet.wm.enable {
  universe.hm = [
    {
      gtk = {
        enable = true;

        gtk3 = {
          bookmarks = [
            "file:///home/${user.name}/Desktop"
            "file:///home/${user.name}/Downloads"
            "file:///home/${user.name}/Documents"
            "file:///home/${user.name}/Pictures"
            "file:///home/${user.name}/Music"
            "file:///home/${user.name}/nixos"
            "file:///home/${user.name}/notes"
            "file:///home/${user.name}/r"
          ];
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
