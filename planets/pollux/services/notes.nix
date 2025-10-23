{ config, ... }:

let
  inherit (config.universe) domain;
  port = 5718;
  host = "notes.${domain}";

  routerName = "notes";
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
    root = "/var/www/notes";
    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri.html $uri/ =404";
    };
    extraConfig = ''
      error_page 404 /404.html;
    '';
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
