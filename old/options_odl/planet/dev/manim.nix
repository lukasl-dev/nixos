{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.dev) manim;
in
{
  options.planet.dev.manim = {
    enable = lib.mkEnableOption "Enable manim";
  };

  config = lib.mkIf manim.enable {
    environment.systemPackages = [ pkgs.unstable.manim ];
  };
}
