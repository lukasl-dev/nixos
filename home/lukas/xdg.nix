{ config, ... }:

{
  xdg = {
    enable = true;

    cacheHome = config.home.homeDirectory + "/.local/cache";
    configHome = config.home.homeDirectory + "/.config";

    userDirs = {
      enable = true;
      createDirectories = true;
    };

    portal = {
      enable = true;

      xdgOpenUsePortal = true;
      config = {
        common.default = [ "gtk" ];
      };
    };

    mimeApps =
      let
        browser = [ "brave.desktop" ];
        sioyek = [ "sioyek.desktop" ];
      in
      {
        enable = true;

        defaultApplications = {
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

          "application/pdf" = sioyek;
        };
      };
  };
}
