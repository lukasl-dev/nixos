{
  pkgs, config, ... }:

let
  domain = config.universe.domain;
  user = config.universe.user;

  port = 5291;
in
{
  services.freshrss = {
    enable = true;

    package = pkgs.unstable.freshrss;

    defaultUser = user.name;
    passwordFile = config.sops.secrets."planets/pollux/freshrss/password".path;

    webserver = "nginx";
    virtualHost = "rss";
    baseUrl = "https://rss.${domain}";
  };

  sops.secrets = {
    "planets/pollux/freshrss/password" = {
      owner = config.services.freshrss.user;
    };
  };

  services.nginx.virtualHosts.${config.services.freshrss.virtualHost} = {
    listen = [
      {
        addr = "127.0.0.1";
        port = port;
      }
    ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.rss = {
      rule = "Host(`rss.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "rss";
    };
    services.rss = {
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
