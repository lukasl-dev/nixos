{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (wm) hyprland;
in
{
  options.planet.programs.obsidian = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable obsidian";
    };
  };

  config = lib.mkIf config.planet.programs.obsidian.enable {
    environment.systemPackages = [
      (
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
          pkgs.unstable.obsidian
      )
    ];

    universe.hm = [
      {
        xdg.mimeApps.defaultApplications = {
          "x-scheme-handler/obsidian" = "obsidian.desktop";
        };
      }
    ];
  };
}
