{
  config,
  lib,
  pkgs,
  ...
}:

let
  wm = config.planet.wm;

  seahorse = config.planet.programs.seahorse;
in
{
  options.planet.programs.seahorse = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable seahorse";
    };
  };

  config = lib.mkIf seahorse.enable {
    programs.seahorse.enable = true;

    environment.systemPackages = with pkgs; [ libsecret ];
  };
}
