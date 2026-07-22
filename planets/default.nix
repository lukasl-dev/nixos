{ config, lib, ... }:

let
  inherit (config) planet;
in
{
  imports = [
    ./age.nix
    ./hjem.nix
    ./ssh.nix
    ./time.nix
    ./travellers.nix
  ];

  options.planet = {
    name = lib.mkOption {
      type = lib.types.str;
      example = "vega";
    };

    modules = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
    };
  };

  config = {
    networking.hostName = planet.name;
  };
}
