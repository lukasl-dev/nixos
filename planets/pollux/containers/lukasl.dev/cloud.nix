let
  meta = import ./meta.nix;

  sub = "cloud";
  hostName = "${sub}.${meta.domain}";

  port = 8314;
in
{
  pollux.containers.${meta.container} = [
    (
      { config, pkgs, ... }:
      let
        inherit (config.sops) secrets;
      in
      {
        services = {
          nextcloud = {
            enable = true;
            package = pkgs.nextcloud32;

            inherit hostName;

            config.adminpassFile = secrets."planets/pollux/nextcloud/password".path;
            config.dbtype = "sqlite";

            # configureRedis = true;
            # caching.apcu = true;

            settings = {
              overwriteprotocol = "https";
              # "memcache.local" = "\\OC\\Memcache\\APCu";
            };
          };

          nginx.virtualHosts.${hostName} = {
            listen = [
              {
                addr = meta.address.local;
                inherit port;
              }
            ];
          };

          redis.servers.nextcloud = {
            enable = true;
            port = 0;
            user = "nextcloud";
          };
        };

        networking.firewall.allowedTCPPorts = [ port ];

        sops.secrets = {
          "planets/pollux/nextcloud/password" = {
            owner = "nextcloud";
          };
        };
      }
    )
  ];

  services.traefik.dynamicConfigOptions.http =
    let
      name = meta.router sub;
      serversTransport = "cloud-timeouts";
    in
    {
      routers.${name} = {
        rule = "Host(`${hostName}`)";
        entryPoints = [ "websecure" ];
        service = name;
      };
      services.${name} = {
        loadBalancer = {
          passHostHeader = true;
          servers = [
            {
              url = "http://${meta.address.local}:${toString port}";
            }
          ];
          inherit serversTransport;
        };
      };
      serversTransports.${serversTransport}.forwardingTimeouts = {
        dialTimeout = "30s";
        responseHeaderTimeout = "0s";
        idleConnTimeout = "0s";
      };
    };
}
