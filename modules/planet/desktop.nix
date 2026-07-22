{ lib, ... }:

{
  options.planet = {
    desktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };
}
