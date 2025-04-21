{ meta, ... }:

{
  gtk = {
    enable = true;

    # theme = {
    #   name = "Adwaita-dark";
    #   package = pkgs.adwaita-icon-theme;
    # };

    gtk3 = {
      bookmarks = [
        "file:///home/${meta.user.name}/Desktop"
        "file:///home/${meta.user.name}/Downloads"
        "file:///home/${meta.user.name}/Documents"
        "file:///home/${meta.user.name}/Pictures"
        "file:///home/${meta.user.name}/Music"

        "file:///home/${meta.user.name}/nixos"
        "file:///home/${meta.user.name}/notes"
        "file:///home/${meta.user.name}/r"
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
