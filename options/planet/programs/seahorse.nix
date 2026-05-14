{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) display;
  inherit (config.planet.programs) seahorse;
in
{
  options.planet.programs = {
    seahorse = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = display.enable;
        description = "Enable seahorse";
      };
    };
  };

  config = lib.mkIf seahorse.enable {
    programs.seahorse.enable = true;

    environment.systemPackages = with pkgs; [ libsecret ];
  };
}
