{ config, lib, ... }:

let
  wm = config.planet.wm;
  brave = config.planet.programs.brave;
  zen = config.planet.programs.zen;
  helium = config.planet.programs.helium;

  defaultApps = config.planet.xdg.defaultApps;
in
{
  options.planet.xdg.defaultApps = {
    browser = lib.mkOption {
      type = lib.types.enum [
        "zen"
        "brave"
        "helium"
      ];
      default = "helium";
      description = "Default web browser";
      example = "zen";
    };

    pdf = lib.mkOption {
      type = lib.types.enum [
        "zen"
        "brave"
        "helium"
      ];
      default = "helium";
      description = "Default pdf viewer";
      example = "zen";
    };
  };

  config = {
    assertions = lib.mkIf wm.enable [
      {
        assertion = defaultApps.browser != "brave" || brave.enable;
        message = "🌍 To use brave as default browser, you must `planet.programs.brave.enable = true;`";
      }
      {
        assertion = defaultApps.browser != "zen" || zen.enable;
        message = "🌍 To use zen as default browser, you must `planet.programs.zen.enable = true;`";
      }
      {
        assertion = defaultApps.browser != "helium" || helium.enable;
        message = "🌍 To use helium as default browser, you must `planet.programs.helium.enable = true;`";
      }

      {
        assertion = defaultApps.pdf != "brave" || brave.enable;
        message = "🌍 To use brave as default pdf viewer, you must `planet.programs.brave.enable = true;`";
      }
      {
        assertion = defaultApps.pdf != "zen" || zen.enable;
        message = "🌍 To use zen as default pdf viewer, you must `planet.programs.zen.enable = true;`";
      }
      {
        assertion = defaultApps.pdf != "helium" || helium.enable;
        message = "🌍 To use helium as default pdf viewer, you must `planet.programs.helium.enable = true;`";
      }
    ];

    universe.hm = [
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
                desktopFiles = {
                  brave = "brave.desktop";
                  zen = "zen-beta.desktop";
                  helium = "helium.desktop";
                };
                browser = desktopFiles.${defaultApps.browser};
                pdf = desktopFiles.${defaultApps.pdf};
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
  };
}
