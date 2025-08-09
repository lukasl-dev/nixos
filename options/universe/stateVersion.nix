{ config, lib, ... }:

let
  stateVersion = config.universe.stateVersion;
in
{
  options.universe.stateVersion = lib.mkOption {
    type = lib.types.str;
    description = "The state version to use for things like NixOS and Home Manager.";
    default = "";
    example = "25.05";
  };

  config = {
    assertions = [
      {
        assertion = config.planet.name != "";
        message = "🌍 Please define 'planet.name'.";
      }
    ];

    system.stateVersion = stateVersion;
    universe.hm = [
      {
        home.stateVersion = stateVersion;
      }
    ];
  };
}
