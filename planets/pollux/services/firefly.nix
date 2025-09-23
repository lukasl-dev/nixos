{ config, pkgs-unstable, ... }:

let
  domain = config.universe.domain;

  port = 7128;
in
{
  services.firefly-iii = {
    enable = true;
    package = pkgs-unstable.firefly-iii;

    enableNginx = true;
    virtualHost = "fin.${domain}";

    settings = {
      APP_ENV = "production";
      APP_URL = "https://fin.${domain}";
      APP_KEY_FILE = config.sops.secrets."planets/pollux/firefly/key".path;
      SITE_OWNER = "me@${domain}";
      TRUSTED_PROXIES = "*";
    };
  };

  services.nginx.virtualHosts.${config.services.firefly-iii.virtualHost} = {
    enableACME = false;
    listen = [
      {
        addr = "127.0.0.1";
        port = 7128;
      }
    ];
  };

  sops.secrets."planets/pollux/firefly/key" = {
    owner = config.services.firefly-iii.user;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.finances = {
      rule = "Host(`fin.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "finances";
    };
    services.finances = {
      loadBalancer = {
        passHostHeader = true;
        servers = [
          {
            url = "http://localhost:${toString port}";
          }
        ];
      };
    };
  };
}
