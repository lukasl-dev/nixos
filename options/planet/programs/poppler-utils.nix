{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) wm;
in
{
  options.planet.programs.poppler-utils = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable poppler-utils";
    };
  };

  config = lib.mkIf config.planet.programs.poppler-utils.enable {
    environment.systemPackages = with pkgs; [ poppler-utils ];
  };
}
