# { pkgs, ... }:

{
  gtk = {
    enable = true;

    # theme = {
    #   name = "Adwaita-dark";
    #   package = pkgs.adwaita-icon-theme;
    # };

    gtk3 = {
      bookmarks = [
        "file:///home/lukas/Desktop"
        "file:///home/lukas/Downloads"
        "file:///home/lukas/Documents"
        "file:///home/lukas/Pictures"
        "file:///home/lukas/Music"

        "file:///home/lukas/nixos"
        "file:///home/lukas/notes"
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
