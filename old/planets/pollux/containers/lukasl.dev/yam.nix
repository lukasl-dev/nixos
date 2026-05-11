let
  meta = import ./meta.nix;

  sub = "yam";
  host = "${sub}.${meta.domain}";
  port = 5772;

  stateDir = "/var/lib/yamtrack";
  redisDir = "/var/lib/yamtrack-redis";
in
{
  pollux.containers.${meta.container} = [
    (
      { config, pkgs, ... }:
      let
        inherit (config.virtualisation.oci-containers) backend;
        inherit (config.sops) templates;
      in
      {
        virtualisation.oci-containers.containers = {
          yamtrack = {
            image = "ghcr.io/fuzzygrim/yamtrack:latest";
            ports = [ "${toString port}:8000" ];
            environment = {
              TZ = "Europe/Berlin";
              REDIS_URL = "redis://yamtrack-redis:6379";
              URLS = "https://${host}";
              REGISTRATION = "False";
            };
            environmentFiles = [ templates."planets/pollux/yamtrack/env".path ];
            volumes = [ "${stateDir}:/yamtrack/db" ];
            dependsOn = [ "yamtrack-redis" ];
            extraOptions = [ "--network=yamtrack" ];
          };

          yamtrack-redis = {
            image = "redis:8-alpine";
            volumes = [ "${redisDir}:/data" ];
            extraOptions = [
              "--network=yamtrack"
              "--network-alias=yamtrack-redis"
            ];
          };
        };

        sops = {
          secrets."planets/pollux/yamtrack/secret" = { };
          templates."planets/pollux/yamtrack/env".content = ''
            SECRET=${config.sops.placeholder."planets/pollux/yamtrack/secret"}
            ADMIN_ENABLED=True
          '';
        };

        networking.firewall.allowedTCPPorts = [ port ];

        systemd.tmpfiles.rules = [
          "d ${stateDir} 0750 root root -"
          "d ${redisDir} 0750 root root -"
        ];

        systemd.services.create-yamtrack-network = {
          description = "Create Docker network for Yamtrack";
          after = [ "docker.service" ];
          requires = [ "docker.service" ];
          wantedBy = [
            "${backend}-yamtrack.service"
            "${backend}-yamtrack-redis.service"
          ];
          before = [
            "${backend}-yamtrack.service"
            "${backend}-yamtrack-redis.service"
          ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            ${pkgs.docker}/bin/docker network inspect yamtrack >/dev/null 2>&1 \
              || ${pkgs.docker}/bin/docker network create yamtrack
          '';
        };
      }
    )
  ];

  services.traefik.dynamicConfigOptions.http =
    let
      name = meta.router sub;
    in
    {
      routers.${name} = {
        rule = "Host(`${host}`)";
        entryPoints = [ "websecure" ];
        service = name;
      };
      services.${name} = {
        loadBalancer.servers = [
          {
            url = "http://${meta.address.local}:${toString port}";
          }
        ];
      };
    };
}
