{ config, ... }:

let
  domain = config.universe.domain;

  prometheus = config.services.prometheus;
in
{
  services.prometheus = {
    enable = true;

    port = 8831;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.prometheus = {
      rule = "Host(`metrics.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "prometheus";
    };
    services.prometheus = {
      loadBalancer.servers = [
        {
          url = "http://${prometheus.listenAddress}:${toString prometheus.port}";
        }
      ];
    };
  };
}
