{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  wm = config.planet.wm;

  bitwarden = config.planet.programs.bitwarden;
in
{
  options.planet.programs.bitwarden = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable bitwarden";
      example = "true";
    };
  };

  config = lib.mkIf bitwarden.enable {
    environment.systemPackages = [
      pkgs-unstable.bitwarden
      pkgs-unstable.bitwarden-cli
    ];
  };
}
