{
  meta,
  config,
  pkgs-unstable,
  ...
}:

{
  services.freshrss = {
    enable = true;

    package = pkgs-unstable.freshrss;

    defaultUser = meta.user.name;
    defaultPasswordFile = config.sops.secrets."freshrss/password".path;

    webserver = "nginx";
    virtualHost = "rss";
    baseUrl = "https://rss.${meta.domain}";
  };

  sops.secrets = {
    "freshrss/password" = { };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.rss = {
      rule = "Host(`rss.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "rss";
    };
    services.rss = {
      loadBalancer.servers = [
        {
          url = "http://localhost:${toString config.services.nginx.defaultHTTPListenPort}";
        }
      ];
    };
  };
}
