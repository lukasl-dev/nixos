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

  package = pkgs.rustPlatform.buildRustPackage {
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

  pluginRoot = "${package}/share/herdr/plugins/herdr-navigator";

  settingsFile = (pkgs.formats.toml { }).generate "herdr-navigator-config.toml" {
    picker.vim_mode = true;
  };
in
{
  config = {
    planet.programs.herdr.pluginRoots = [ pluginRoot ];

    planet.programs.herdr.settings.keys.command = [
      {
        key = "prefix+t";
        type = "plugin_action";
        command = "herdr-navigator.open";
        description = "jump to anything";
      }
    ];

    hjem.users = atlas.travellers.forEach planet (_: {
      xdg.config.files."herdr/plugins/config/herdr-navigator/config.toml".source =
        settingsFile;
    });
  };
}
