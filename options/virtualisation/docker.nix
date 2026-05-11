{ config, lib, ... }:

let
  inherit (config.planet.virtualisation) docker;
in
{
  options.planet.virtualisation = {
    docker = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable docker";
        default = true;
        example = "true";
      };
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
