{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) wm;

  inherit (config.planet.programs) bitwarden;
in
{
  options.planet.programs.bitwarden = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable bitwarden";
      example = "true";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.unstable.bitwarden-desktop;
      description = "Package used for Bitwarden.";
      example = "pkgs.unstable.bitwarden-desktop";
    };

    launch = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = lib.getExe bitwarden.package;
      description = "Command used to launch Bitwarden.";
      example = "bitwarden";
    };
  };

  config = lib.mkIf bitwarden.enable {
    environment.systemPackages = [
      bitwarden.package
      pkgs.unstable.bitwarden-cli
    ];
  };
}
