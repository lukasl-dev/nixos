{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (wm) hyprland;

  inherit (config.planet.programs) obsidian;
in
{
  options.planet.programs.obsidian = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
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

  config = lib.mkIf obsidian.enable {
    environment.systemPackages = [ obsidian.package ];

    planet.wm.hyprland.bindings =
      let
        cmd = lib.getExe obsidian.package;
      in
      [
        {
          type = "exec";
          keys = [ "P" ];
          command = cmd;
        }
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
