{ config, lib, ... }:

let
  wm = config.planet.wm;
  brave = config.planet.programs.brave;
  zen = config.planet.programs.zen;

  defaultApps = config.planet.xdg.defaultApps;
in
{
  options.planet.xdg.defaultApps = {
    browser = lib.mkOption {
      type = lib.types.enum [
        "zen"
        "brave"
      ];
      default = "zen";
      description = "Default web browser";
      example = "zen";
    };

    pdf = lib.mkOption {
      type = lib.types.enum [
        "zen"
        "brave"
      ];
      default = "zen";
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
        assertion = defaultApps.pdf != "brave" || brave.enable;
        message = "🌍 To use brave as default pdf viewer, you must `planet.programs.brave.enable = true;`";
      }
      {
        assertion = defaultApps.pdf != "zen" || zen.enable;
        message = "🌍 To use zen as default pdf viewer, you must `planet.programs.zen.enable = true;`";
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
                browser = if (defaultApps.browser == "brave") then "brave.desktop" else "zen-beta.desktop";
                pdf = if (defaultApps.pdf == "brave") then "brave.desktop" else "zen-beta.desktop";
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
                "inode/directory" = "yazi.desktop";
              };
          };
        };
      }
    ];
  };
}
