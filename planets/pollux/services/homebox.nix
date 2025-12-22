{ config, ... }:

let
  inherit (config.universe) domain;
  port = 7745;
  host = "box.${domain}";

  routerName = "homebox";
  serviceName = routerName;

  upstream = "http://127.0.0.1:${toString port}";
in
{
  services.homebox = {
    enable = true;

    settings = {
      HBOX_WEB_PORT = toString port;
      HBOX_WEB_HOST = "127.0.0.1";
      HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
      HBOX_OPTIONS_GITHUB_RELEASE_CHECK = "false";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.${routerName} = {
      rule = "Host(`${host}`)";
      entryPoints = [ "websecure" ];
      service = serviceName;
    };

    services.${serviceName} = {
      loadBalancer = {
        passHostHeader = true;
        servers = [
          { url = upstream; }
        ];
      };
    };
  };
}
