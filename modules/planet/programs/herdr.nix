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
    };
  };
in
{
  options.planet.programs.herdr.package = lib.mkOption {
    type = lib.types.package;
    readOnly = true;
    default = inputs.herdr.packages.${system}.default;
    description = "Package used for Herdr.";
  };

  config = {
    environment.systemPackages = [ planet.programs.herdr.package ];

    hjem.users = atlas.travellers.forEach planet (_: {
      xdg.config.files."herdr/config.toml".source = settingsFile;
    });
  };
}
