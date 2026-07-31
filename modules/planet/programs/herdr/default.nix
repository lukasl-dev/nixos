{
  atlas,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (pkgs.stdenv.hostPlatform) system;

  package = inputs.herdr.packages.${system}.default;

  settingsFormat = pkgs.formats.toml { };
in
{
  imports = [ ./navigator.nix ];

  options.planet.programs.herdr = {
    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = package;
      description = "Package used for Herdr.";
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = "Settings written to Herdr's config.toml.";
    };

    pluginRoots = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Plugin roots linked into Herdr's plugin registry.";
    };
  };

  config = {
    planet.programs.herdr.settings = {
      onboarding = false;

      keys = {
        prefix = "ctrl+a";

        navigate_workspace_up = [
          "k"
          "up"
        ];
        navigate_workspace_down = [
          "j"
          "down"
        ];

        navigate_pane_left = "h";
        navigate_pane_down = "";
        navigate_pane_up = "";
        navigate_pane_right = "l";
      };
    };

    environment.systemPackages = [ planet.programs.herdr.package ];

    hjem.users = atlas.travellers.forEach planet (_: {
      xdg.config.files = {
        "herdr/config.toml".source =
          settingsFormat.generate "herdr-config.toml" planet.programs.herdr.settings;

        "herdr/plugins.json".source = pkgs.runCommand "herdr-plugins.json" { } ''
          export HOME="$TMPDIR/home"
          export XDG_CONFIG_HOME="$TMPDIR/config"

          mkdir -p "$HOME" "$XDG_CONFIG_HOME"
          ${lib.concatMapStringsSep "\n" (
            pluginRoot: "${lib.getExe package} plugin link ${pluginRoot}"
          ) planet.programs.herdr.pluginRoots}
          cp "$XDG_CONFIG_HOME/herdr/plugins.json" "$out"
        '';
      };
    });
  };
}
