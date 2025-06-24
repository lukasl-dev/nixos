{ config, ... }:

{
  xdg = {
    enable = true;

    cacheHome = config.home.homeDirectory + "/.local/cache";

    userDirs = {
      enable = true;
      createDirectories = true;
    };

    mimeApps =
      let
        browser = [ "zen-beta.desktop" ];
        sioyek = [ "sioyek.desktop" ];
        imageViewer = if config.programs.feh.enable then [ "feh.desktop" ] else null;
        videoPlayer = if config.programs.mpv.enable then [ "mpv.desktop" ] else null;
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

          "image/jpeg" = imageViewer;
          "image/jpg" = imageViewer;
          "image/png" = imageViewer;
          "image/gif" = imageViewer;
          "image/bmp" = imageViewer;
          "image/tiff" = imageViewer;
          "image/webp" = imageViewer;
          "image/x-portable-pixmap" = imageViewer;
          "image/x-portable-graymap" = imageViewer;
          "image/x-portable-bitmap" = imageViewer;
          "image/x-portable-anymap" = imageViewer;

          "video/mp4" = videoPlayer;
          "video/mpeg" = videoPlayer;
          "video/quicktime" = videoPlayer;
          "video/x-msvideo" = videoPlayer;
          "video/x-ms-wmv" = videoPlayer;
          "video/webm" = videoPlayer;
          "video/ogg" = videoPlayer;
          "video/x-matroska" = videoPlayer;
          "video/x-flv" = videoPlayer;
          "video/3gpp" = videoPlayer;
          "video/x-ms-asf" = videoPlayer;
        };
      };

    # portal = {
    #   enable = true;
    #   config = {
    #     common.default = [ "gtk" ];
    #   };
    #   extraPortals = [
    #     pkgs.xdg-desktop-portal-gtk
    #   ];
    #   xdgOpenUsePortal = true;
    # };
  };
}
