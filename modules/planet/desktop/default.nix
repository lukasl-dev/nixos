{ lib, ... }:

{
  imports = [ ./fonts.nix ];

  options.planet.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
}
