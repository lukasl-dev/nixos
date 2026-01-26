{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.planet.development.manim = {
    enable = lib.mkEnableOption "Enable manim";
  };

  config = lib.mkIf config.planet.development.manim.enable {
    environment.systemPackages = with pkgs.unstable; [ manim ];
  };
}
