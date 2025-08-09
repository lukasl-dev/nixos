{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  bitwarden = config.planet.programs.bitwarden;
in
{
  options.planet.programs.bitwarden = {
    enable = lib.mkEnableOption "Enable bitwarden";
  };

  config = lib.mkIf bitwarden.enable {
    environment.systemPackages = [
      pkgs-unstable.bitwarden
      pkgs-unstable.bitwarden-cli
    ];
  };
}
