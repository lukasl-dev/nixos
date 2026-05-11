{ config, ... }:

let
  inherit (config.universe) domain;

  host = "status.${domain}";
  port = 3141;
in
{
  services.uptime-kuma = {
    enable = true;
    settings = {
      UPTIME_KUMA_HOST = "127.0.0.1";
      UPTIME_KUMA_PORT = toString port;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.uptime-kuma = {
      rule = "Host(`${host}`)";
      entryPoints = [ "websecure" ];
      service = "uptime-kuma";
      tls = { };
    };
    services.uptime-kuma.loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${toString port}";
      }
    ];
  };
}
