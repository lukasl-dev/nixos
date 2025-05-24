{ meta, pkgs-unstable, ... }:

{
  imports = [ ../desktop/gtk.nix ];

  home.packages = [ pkgs-unstable.nautilus ];

  gtk.gtk3 = {
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
  };
}
