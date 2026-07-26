{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) planet;

  bookmarks =
    traveller:
    map (directory: "file:///home/${traveller.user.name}/${directory}") [
      "Desktop"
      "Downloads"
      "Documents"
      "Pictures"
      "Music"
      "nixos"
      "notes"
      "r"
    ];
in
{
  config = lib.mkIf planet.desktop.enable {
    hjem.users = atlas.travellers.forEach planet (traveller: {
      rum.misc.gtk = {
        enable = true;
        bookmarks = bookmarks traveller;
        settings = {
          application-prefer-dark-theme = true;
          error-bell = false;
        };
      };
    });
  };
}
