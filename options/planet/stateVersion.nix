{ config, lib, ... }:

let
  inherit (config.planet) stateVersion;
in
{
  options.planet = {
    stateVersion = lib.mkOption {
      type = lib.types.str;
      description = "The state version to use for things like NixOS and Home Manager.";
      default = "";
      example = "25.05";
    };
  };

  config = {
    assertions = [
      {
        assertion = stateVersion != "";
        message = "🪐 Please define 'planet.stateVersion'.";
      }
    ];

    system.stateVersion = stateVersion;
    planet.hm = [
      {
        home.stateVersion = stateVersion;
      }
    ];
  };
}
