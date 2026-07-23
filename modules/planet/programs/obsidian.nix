{
  config,
  lib,
  pkgs,
  atlas,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.programs) obsidian;

  wrapped = pkgs.obsidian.override {
    commandLineArgs = lib.concatStringsSep " " [
      "--ozone-platform=wayland"
      "--enable-features=WaylandLinuxDrmSyncobj"
      "--disable-gpu-memory-buffer-video-frames"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
    ];
  };

  launcher = pkgs.writeShellScriptBin "obsidian" ''
    case "''${1-}" in
      dev:*|links|backlinks|unresolved|orphans|deadends|read|files|search|search:context|outline|vault=*)
        exec ${lib.getExe' wrapped "obsidian-cli"} "$@"
        ;;
      *)
        exec ${lib.getExe wrapped} "$@"
        ;;
    esac
  '';

  package = pkgs.symlinkJoin {
    name = "obsidian";
    paths = [
      launcher
      wrapped
    ];

    inherit (wrapped) meta;
  };
in
{
  options.planet.programs.obsidian = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = planet.desktop.enable;
      description = "Enable Obsidian.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = package;
      description = "Wrapped Obsidian package.";
    };
  };

  config = lib.mkIf obsidian.enable {
    environment.systemPackages = [ obsidian.package ];

    hjem.users = atlas.travellers.forEach planet (_: {
      xdg.mime-apps.default-applications."x-scheme-handler/obsidian" =
        "obsidian.desktop";
    });
  };
}
