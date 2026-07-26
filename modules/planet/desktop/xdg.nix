{
  config,
  lib,
  pkgs,
  atlas,
  ...
}:

let
  inherit (config) planet;

  defaultApplications = {
    "image/png" = "feh.desktop";
    "image/jpeg" = "feh.desktop";
    "image/jpg" = "feh.desktop";
    "image/webp" = "feh.desktop";
    "image/gif" = "feh.desktop";
    "image/bmp" = "feh.desktop";
    "image/tiff" = "feh.desktop";

    "inode/directory" = "yazi.desktop";
  };

  userDirectories = [
    ".cache"
    ".config"
    ".local"
    ".local/share"
    ".local/state"
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Public"
    "Templates"
    "Videos"
  ];

  tmpfiles = lib.concatMap (
    traveller:
    lib.concatMap (
      directory:
      let
        path = "/home/${traveller.user.name}/${directory}";
      in
      [
        "d ${path} 0700 ${traveller.user.name} users - -"
        "z ${path} 0700 ${traveller.user.name} users - -"
      ]
    ) userDirectories
  ) (atlas.travellers.all planet);
in
{
  config = lib.mkIf planet.desktop.enable {
    hjem.users = atlas.travellers.forEach planet (_: {
      packages = [ pkgs.xdg-user-dirs ];

      xdg = {
        mime-apps.default-applications = defaultApplications;

        config.files = {
          "user-dirs.dirs".text = ''
            XDG_DESKTOP_DIR="$HOME/Desktop"
            XDG_DOCUMENTS_DIR="$HOME/Documents"
            XDG_DOWNLOAD_DIR="$HOME/Downloads"
            XDG_MUSIC_DIR="$HOME/Music"
            XDG_PICTURES_DIR="$HOME/Pictures"
            XDG_PUBLICSHARE_DIR="$HOME/Public"
            XDG_TEMPLATES_DIR="$HOME/Templates"
            XDG_VIDEOS_DIR="$HOME/Videos"
          '';

          "user-dirs.conf".text = ''
            enabled=False
          '';
        };
      };
    });

    systemd.tmpfiles.rules = tmpfiles;
  };
}
