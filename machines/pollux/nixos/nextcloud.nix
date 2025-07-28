{
  meta,
  config,
  pkgs,
  ...
}:

let
  port = 8314;
in
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;

    # nextcloud uses nginx as webserver
    hostName = "cloud.${meta.domain}";

    config.adminpassFile = config.sops.secrets."nextcloud/password".path;
    config.dbtype = "sqlite";

    settings = {
      overwriteprotocol = "https";
    };
  };

  environment.systemPackages = [ pkgs.nextcloud-client ];

  sops.secrets = {
    "nextcloud/password" = {
      owner = "nextcloud";
    };
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    listen = [
      {
        addr = "127.0.0.1";
        port = port;
      }
    ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.cloud = {
      rule = "Host(`cloud.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "cloud";
    };
    services.cloud = {
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
