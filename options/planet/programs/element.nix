{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (wm) hyprland;

  element = config.planet.programs.element;
in
{
  options.planet.programs.element = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable element";
      example = "true";
    };
  };

  config = lib.mkIf element.enable {
    universe.hm = [
      {
        programs.element-desktop = {
          enable = true;
          package =
            if hyprland.enable then
              pkgs.unstable.element-desktop.overrideAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.unstable.makeWrapper ];
                postFixup = (old.postFixup or "") + ''
                  wrapProgram $out/bin/element-desktop \
                    --add-flags "--enable-features=WaylandLinuxDrmSyncobj" \
                    --add-flags "--disable-gpu-memory-buffer-video-frames" \
                    --add-flags "--ignore-gpu-blocklist" \
                    --add-flags "--enable-gpu-rasterization" \
                    --add-flags "--enable-zero-copy" \
                    --add-flags "--disable-gpu-sandbox"
                '';
              })
            else
              pkgs.unstable.element-desktop;
        };
      }
    ];
  };
}
