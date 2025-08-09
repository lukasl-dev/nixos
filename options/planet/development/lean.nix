{
  config,
  pkgs-unstable,
  lib,
  ...
}:

{
  options.planet.development.lean = {
    enable = lib.mkEnableOption "Enable lean";
  };

  config = lib.mkIf config.planet.development.lean.enable {
    environment.systemPackages = with pkgs-unstable; [
      lean4
    ];
  };
}
