{ config, lib, ... }:

let
  docker = config.planet.services.docker;
in
{
  options.planet.services.docker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable docker";
      default = true;
      example = "true";
    };
  };

  config = lib.mkIf docker.enable {
    virtualisation = {
      docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
      oci-containers.backend = "docker";
    };
  };
}
