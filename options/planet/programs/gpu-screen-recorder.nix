{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (config.planet.programs) gpu-screen-recorder;
in
{
  options.planet.programs.gpu-screen-recorder = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable gpu-screen-recorder";
    };
  };

  config = lib.mkIf gpu-screen-recorder.enable {
    programs.gpu-screen-recorder.enable = true;
    environment.systemPackages = [ pkgs.gpu-screen-recorder ];
  };
}
