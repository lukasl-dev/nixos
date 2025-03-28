{
  meta,
  config,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    pkgs.nextcloud-client
  ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;

    # nextcloud uses nginx as webserver
    hostName = "cloud.lukasl.dev";

    config.adminpassFile = config.sops.secrets."nextcloud/password".path;
    config.dbtype = "sqlite"; # TODO: use postgres

    settings = {
      overwriteprotocol = "https";
    };
  };

  sops.secrets = {
    "nextcloud/password" = {
      owner = "nextcloud";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.cloud = {
      rule = "Host(`cloud.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "cloud";
    };
    services.cloud = {
      loadBalancer.servers = [
        {
          url = "http://localhost:${toString config.services.nginx.defaultHTTPListenPort}";
        }
      ];
    };
  };
}
