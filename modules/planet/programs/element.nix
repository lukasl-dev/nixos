{
  config,
  lib,
  pkgs,
  atlas,
  ...
}:

let
  inherit (config) catppuccin planet;
  inherit (planet.programs) element;

  package = pkgs.symlinkJoin {
    name = "element";
    paths = [ pkgs.element-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram "$out/bin/element-desktop" \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-features=WaylandLinuxDrmSyncobj" \
        --add-flags "--disable-gpu-memory-buffer-video-frames" \
        --add-flags "--ignore-gpu-blocklist" \
        --add-flags "--enable-gpu-rasterization" \
        --add-flags "--enable-zero-copy"
    '';

    inherit (pkgs.element-desktop) meta;
  };

  theme = lib.importJSON "${catppuccin.sources.element}/${catppuccin.flavor}/${catppuccin.accent}.json";
in
{
  options.planet.programs.element = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = planet.desktop.enable;
      description = "Enable the Element Matrix client.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = package;
      description = "Wrapped Element package.";
    };

    launch = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = lib.getExe element.package;
      description = "Command used to launch Element.";
    };
  };

  config = lib.mkIf element.enable {
    environment.systemPackages = [ element.package ];

    systemd.user.services.element = {
      description = "Element Matrix client";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      unitConfig.PartOf = [ "graphical-session.target" ];
      serviceConfig.ExecStart = element.launch;
    };

    hjem.users = atlas.travellers.forEach planet (_: {
      xdg = {
        config.files."Element/config.json".source = (pkgs.formats.json { }).generate "element-config.json" {
          default_theme = theme.name;
          setting_defaults.custom_themes = [ theme ];
        };

        mime-apps.default-applications = {
          "x-scheme-handler/element" = "element-desktop.desktop";
          "x-scheme-handler/io.element.desktop" = "element-desktop.desktop";
        };
      };
    });
  };
}
