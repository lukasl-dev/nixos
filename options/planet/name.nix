{ config, lib, ... }:

{
  options.planet.name = lib.mkOption {
    type = lib.types.str;
    description = "The name of the planet.";
    default = "";
    example = "earth";
  };

  config = {
    assertions = [
      {
        assertion = config.planet.name != "";
        message = "🌍 Please define 'planet.name'.";
      }
    ];

    networking.hostName = lib.mkDefault config.planet.name;
  };
}
