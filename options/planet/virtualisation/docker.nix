{ config, lib, ... }:

let
  inherit (config.planet.virtualisation) docker;
  inherit (config.planet.networking) dns;
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
        daemon.settings.dns = [ dns.dockerAddress ];

        rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings.dns = [ dns.dockerAddress ];
        };
      };
      oci-containers.backend = "docker";
    };
  };
}
