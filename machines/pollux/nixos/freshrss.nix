{
  meta,
  config,
  pkgs-unstable,
  ...
}:

let
  port = 5291;
in
{
  services.freshrss = {
    enable = true;

    package = pkgs-unstable.freshrss;

    defaultUser = meta.user.name;
    passwordFile = config.sops.secrets."freshrss/password".path;

    webserver = "nginx";
    virtualHost = "rss";
    baseUrl = "https://rss.${meta.domain}";
  };

  sops.secrets = {
    "freshrss/password" = {
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
      rule = "Host(`rss.${meta.domain}`)";
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
