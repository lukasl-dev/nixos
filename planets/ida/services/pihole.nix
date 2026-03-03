{ config, ... }:

let
  inherit (config.universe) domain;
  host = "dns.${domain}";
  webPort = 2718;
in
{
  services.pihole-ftl = {
    enable = true;

    settings = {
      dns.upstreams = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };

  services.pihole-web = {
    enable = true;
    hostName = host;
    ports = [ webPort ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.pihole = {
      rule = "Host(`${host}`)";
      entryPoints = [ "websecure" ];
      service = "pihole";
      tls = { };
    };

    services.pihole.loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${toString webPort}";
      }
    ];
  };
}
