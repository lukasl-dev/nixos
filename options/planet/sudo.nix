{ config, lib, ... }:

let
  inherit (config.planet) sudo;
in
{
  options.planet.sudo = {
    password = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Require password for sudo";
    };
  };

  config = {
    security.sudo = {
      enable = true;
      wheelNeedsPassword = sudo.password;
    };
  };
}
