{ config, lib, ... }:

let
  domain = config.universe.domain;
in
{
  options.universe.domain = lib.mkOption {
    type = lib.types.str;
    description = "The domain of the universe.";
    default = "";
    example = "example.com";
  };

  config = {
    assertions = [
      {
        assertion = domain != "";
        message = "🪐 Please define 'universe.domain'.";
      }
    ];

    networking.domain = "nodes.${domain}";
  };
}
