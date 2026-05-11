{ config, ... }:

let
  inherit (config.universe) domain;
  hostName = "restic.${domain}";
  port = 8000;
in
{
  services.restic.server = {
    enable = true;
    dataDir = "/mnt/external/restic";
    listenAddress = "127.0.0.1:${toString port}";
    extraFlags = [ "--no-auth" ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.restic = {
      rule = "Host(`${hostName}`)";
      entryPoints = [ "websecure" ];
      service = "restic";
      tls = { };
    };

    services.restic.loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${toString port}";
      }
    ];
  };
}
