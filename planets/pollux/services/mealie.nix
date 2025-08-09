{ config, pkgs-unstable, ... }:

let
  domain = config.universe.domain;
in
{
  services.mealie = {
    enable = true;
    package = pkgs-unstable.mealie;

    port = 1989;

    settings = {
      ALLOW_SIGNUP = "false";
      TZ = "Europe/Vienna";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.mealy = {
      rule = "Host(`kitchen.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "mealy";
    };
    services.mealy = {
      loadBalancer.servers = [
        {
          url = "http://${config.services.mealie.listenAddress}:${toString config.services.mealie.port}";
        }
      ];
    };
  };
}
