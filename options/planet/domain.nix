{ config, lib, ... }:

let
  inherit (config.planet) domain;
in
{
  options.planet = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain of the planet.";
      default = "";
      example = "lukasl.dev";
    };
  };

  config = {
    assertions = [
      {
        assertion = domain != "";
        message = "🪐 Please define 'planet.domain'.";
      }
    ];

    networking.domain = domain;
  };
}
