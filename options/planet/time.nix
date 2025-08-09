{ config, lib, ... }:

let
  planet = config.planet;
in
{
  options.planet.timeZone = lib.mkOption {
    type = lib.types.str;
    description = "The time zone of the system.";
    default = "";
    example = "Europe/Vienna";
  };

  config = {
    assertions = [
      {
        assertion = config.planet.timeZone != "";
        message = "🌍 Please define 'planet.timeZone'.";
      }
    ];

    time.timeZone = planet.timeZone;
  };
}
