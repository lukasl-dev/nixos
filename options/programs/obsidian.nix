{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.display) hyprland;

  inherit (config.planet.programs) obsidian;
in
{
  options.planet.programs = {
    obsidian = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable obsidian";
      };

      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default =
          if hyprland.enable then
            pkgs.unstable.obsidian.overrideAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.unstable.makeWrapper ];
              postFixup = (old.postFixup or "") + ''
                wrapProgram $out/bin/obsidian \
                  --add-flags "--enable-features=WaylandLinuxDrmSyncobj" \
                  --add-flags "--disable-gpu-memory-buffer-video-frames" \
                  --add-flags "--ignore-gpu-blocklist" \
                  --add-flags "--enable-gpu-rasterization" \
                  --add-flags "--enable-zero-copy" \
                  --add-flags "--disable-gpu-sandbox"
              '';
            })
          else
            pkgs.unstable.obsidian;
        description = "Package used for Obsidian.";
        example = "pkgs.unstable.obsidian";
      };
    };
  };

  config = lib.mkIf obsidian.enable {
    environment.systemPackages = [ obsidian.package ];

    planet.display.hyprland.bind = lib.mkIf hyprland.enable [
      {
        keys = "SUPER + P";
        dispatcher.execCmd = lib.getExe obsidian.package;
      }
    ];

    planet.hm = [
      {
        xdg.mimeApps.defaultApplications = {
          "x-scheme-handler/obsidian" = "obsidian.desktop";
        };
      }
    ];
  };
}
