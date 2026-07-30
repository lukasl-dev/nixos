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

  navigator = pkgs.rustPlatform.buildRustPackage {
    pname = "herdr-navigator";
    version = "0.3.4";
    src = inputs.herdr-navigator;

    cargoLock.lockFile = "${inputs.herdr-navigator}/Cargo.lock";

    postInstall = ''
      pluginRoot=$out/share/herdr/plugins/herdr-navigator
      install -Dm644 ${inputs.herdr-navigator}/herdr-plugin.toml \
        "$pluginRoot/herdr-plugin.toml"
      substituteInPlace "$pluginRoot/herdr-plugin.toml" \
        --replace-fail 'version = "0.3.3"' 'version = "0.3.4"' \
        --replace-fail './target/release/herdr-navigator' \
          "$out/bin/herdr-navigator"
    '';

    meta = {
      description = "Fuzzy navigator for Herdr";
      homepage = "https://github.com/thanhdat77/herdr-navigator";
      license = lib.licenses.mit;
      mainProgram = "herdr-navigator";
      platforms = lib.platforms.unix;
    };
  };

  navigatorPluginRoot = "${navigator}/share/herdr/plugins/herdr-navigator";

  pluginRegistryFile = pkgs.runCommand "herdr-plugins.json" { } ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$TMPDIR/config"

    mkdir -p "$HOME" "$XDG_CONFIG_HOME"
    ${lib.getExe package} plugin link ${navigatorPluginRoot}
    cp "$XDG_CONFIG_HOME/herdr/plugins.json" "$out"
  '';

  settingsFile = (pkgs.formats.toml { }).generate "herdr-config.toml" {
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

      command = [
        {
          key = "prefix+t";
          type = "plugin_action";
          command = "herdr-navigator.open";
          description = "jump to anything";
        }
      ];
    };
  };
in
{
  options.planet.programs.herdr.package = lib.mkOption {
    type = lib.types.package;
    readOnly = true;
    default = package;
    description = "Package used for Herdr.";
  };

  config = {
    environment.systemPackages = [ planet.programs.herdr.package ];

    hjem.users = atlas.travellers.forEach planet (_: {
      xdg.config.files = {
        "herdr/config.toml".source = settingsFile;
        "herdr/plugins.json".source = pluginRegistryFile;
      };
    });
  };
}
