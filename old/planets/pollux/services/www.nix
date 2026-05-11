{ config, ... }:

let
  inherit (config.universe) domain;

  port = 81;
  host = domain;

  routerName = "www";
  serviceName = routerName;

  upstream = "http://127.0.0.1:${toString port}";
in
{
  services.nginx.virtualHosts.${host} = {
    listen = [
      {
        addr = "127.0.0.1";
        inherit port;
      }
    ];
    root = "/var/www/www";
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.${routerName} = {
      rule = "Host(`${host}`)";
      entryPoints = [ "websecure" ];
      service = serviceName;
      priority = 10;
    };

    services.${serviceName} = {
      loadBalancer = {
        passHostHeader = true;
        servers = [
          {
            url = upstream;
          }
        ];
      };
    };
  };
}
