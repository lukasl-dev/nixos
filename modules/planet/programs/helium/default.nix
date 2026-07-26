{
  config,
  lib,
  pkgs,
  atlas,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) helium;

  unwrapped = pkgs.callPackage ./package.nix { };
  wrapped = pkgs.symlinkJoin {
    name = "helium";
    paths = [ unwrapped ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      rm "$out/bin/helium"
      makeWrapper ${lib.getExe unwrapped} "$out/bin/helium" \
        --suffix LD_LIBRARY_PATH : \
          ${lib.escapeShellArg (lib.makeLibraryPath unwrapped.runtimeLibs)} \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-features=WaylandLinuxDrmSyncobj"
    '';

    inherit (unwrapped) meta;
  };
in
{
  options.planet.programs.helium = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = planet.desktop.enable;
      description = "Enable the Helium web browser.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = wrapped;
      description = "Wrapped Helium browser package.";
    };
  };

  config = lib.mkIf helium.enable {
    environment.systemPackages = [ helium.package ];

    hjem.users = atlas.travellers.forEach planet (_: {
      xdg.mime-apps.default-applications =
        let
          app = "helium.desktop";
        in
        {
          "application/x-extension-htm" = app;
          "application/x-extension-html" = app;
          "application/x-extension-shtml" = app;
          "application/x-extension-xht" = app;
          "application/x-extension-xhtml" = app;
          "application/xhtml+xml" = app;
          "application/json" = app;
          "text/html" = app;
          "x-scheme-handler/about" = app;
          "x-scheme-handler/chrome" = app;
          "x-scheme-handler/ftp" = app;
          "x-scheme-handler/http" = app;
          "x-scheme-handler/https" = app;
          "x-scheme-handler/unknown" = app;
          "image/svg+xml" = app;
        };
    });
  };
}
