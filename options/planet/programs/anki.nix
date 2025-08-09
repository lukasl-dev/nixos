{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  anki = config.planet.programs.anki;
in
{
  options.planet.programs.anki = {
    enable = lib.mkEnableOption "Enable Anki";
  };

  config = lib.mkIf anki.enable {
    environment.systemPackages = [ pkgs-unstable.anki ];
  };
}
