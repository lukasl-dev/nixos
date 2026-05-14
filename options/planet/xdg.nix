{ config, lib, ... }:

let
  inherit (config.planet) user display;
in
{
  systemd.tmpfiles.rules = [
    "d /home/${user.name}/.config 0700 ${user.name} users - -"
    "d /home/${user.name}/.local 0700 ${user.name} users - -"
    "d /home/${user.name}/.local/cache 0700 ${user.name} users - -"

    "z /home/${user.name}/.config 0700 ${user.name} users - -"
    "z /home/${user.name}/.local 0700 ${user.name} users - -"
    "z /home/${user.name}/.local/cache 0700 ${user.name} users - -"
  ];

  planet.hm = lib.mkIf display.enable [
    {
      xdg = {
        enable = true;

        userDirs = {
          enable = true;
          createDirectories = true;
        };

        mimeApps = {
          enable = true;

          defaultApplications =
            let
              browser = "helium.desktop";
              pdf = "sioyek.desktop";
            in
            {
              "application/x-extension-htm" = browser;
              "application/x-extension-html" = browser;
              "application/x-extension-shtml" = browser;
              "application/x-extension-xht" = browser;
              "application/x-extension-xhtml" = browser;
              "application/xhtml+xml" = browser;
              "application/json" = browser;
              "text/html" = browser;
              "x-scheme-handler/about" = browser;
              "x-scheme-handler/chrome" = browser;
              "x-scheme-handler/ftp" = browser;
              "x-scheme-handler/http" = browser;
              "x-scheme-handler/https" = browser;
              "x-scheme-handler/unknown" = browser;
              "image/svg+xml" = browser;

              "application/pdf" = pdf;

              "image/png" = "feh.desktop";
              "image/jpeg" = "feh.desktop";
              "image/jpg" = "feh.desktop";
              "image/webp" = "feh.desktop";
              "image/gif" = "feh.desktop";
              "image/bmp" = "feh.desktop";
              "image/tiff" = "feh.desktop";

              "inode/directory" = "yazi.desktop";
            };
        };
      };
    }
  ];
}
