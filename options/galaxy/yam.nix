{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy) domain yam;

  listenAddress = "127.0.0.1";

  stateDir = "/var/lib/yamtrack";
  redisDir = "/var/lib/yamtrack-redis";
  httpPort = "${listenAddress}:${toString yam.port}:8000";

  secret = "galaxy/yam/secret";
  env = "galaxy/yam/env";

  backend = "docker";

  module = {
    virtualisation = {
      docker.enable = true;
      oci-containers.backend = backend;
      oci-containers.containers = {
        yamtrack = {
          image = "ghcr.io/fuzzygrim/yamtrack:latest";
          ports = [ httpPort ];
          environment = {
            TZ = "Europe/Berlin";
            REDIS_URL = "redis://yamtrack-redis:6379";
            URLS = "https://yam.${domain}";
            REGISTRATION = "False";
          };
          environmentFiles = [ age.secrets.${env}.path ];
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
    };

    systemd = {
      tmpfiles.rules = [
        "d ${stateDir} 0750 root root -"
        # redis:8-alpine runs as the in-container `redis` user (uid 999, gid 1000).
        # The data dir must be writable by that user, otherwise background RDB
        # snapshotting fails with "Permission denied" and Redis refuses all writes
        # (the MISCONF error that breaks Celery / Yamtrack searches).
        "d ${redisDir} 0750 999 1000 -"
      ];

      services.create-yamtrack-network = {
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
        script =
          let
            docker = lib.getExe pkgs.docker;
          in
          ''
            ${docker} network inspect yamtrack >/dev/null 2>&1 \
              || ${docker} network create yamtrack
          '';
      };
    };
  };
in
{
  options.galaxy = {
    yam = {
      enable = lib.mkEnableOption "Enable yamtrack server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 5772;
        readOnly = true;
        description = "Port for the yamtrack server.";
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets = {
        ${secret} = {
          rekeyFile = ../../secrets/galaxy/yam/secret.age;
          intermediary = true;
        };

        ${env} = {
          rekeyFile = ../../secrets/galaxy/yam/env.age;
          generator = {
            dependencies = {
              secret = age.secrets.${secret};
            };
            script =
              { decrypt, deps, ... }:
              # bash
              ''
                secret="$(${decrypt} "${deps.secret.file}")"

                cat <<EOF
                SECRET=$secret
                ADMIN_ENABLED=True
                EOF
              '';
          };
        };
      };
    }

    (lib.mkIf yam.enable (
      lib.mkMerge [
        module
        {
          galaxy = {
            proxy.rules = [
              {
                name = "yam";
                to.http = "http://${listenAddress}:${toString yam.port}";
              }
            ];
            backup.paths = [
              stateDir
              redisDir
            ];
          };
        }
      ]
    ))
  ];
}
