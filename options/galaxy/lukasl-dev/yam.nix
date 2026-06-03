{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) domain addresses yam;

  isGuest = yam.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";

  stateDir = "/var/lib/yamtrack";
  redisDir = "/var/lib/yamtrack-redis";
  httpPort =
    if isGuest then "${toString yam.port}:8000" else "${listenAddress}:${toString yam.port}:8000";
  secret = "galaxy/lukasl-dev/yam/secret";
  env = "galaxy/lukasl-dev/yam/env";

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

    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ yam.port ];

    systemd = {
      tmpfiles.rules = [
        "d ${stateDir} 0750 root root -"
        "d ${redisDir} 0750 root root -"
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
  options.galaxy.lukasl-dev = {
    yam = {
      enable = lib.mkEnableOption "Enable yamtrack server";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run yamtrack in the lukasl-dev container or on the host.";
      };

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
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/yam/secret.age;
          intermediary = true;
        };

        ${env} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/yam/env.age;
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
        {
          galaxy.lukasl-dev = {
            proxy.rules = [
              {
                type = "https";
                name = "yam";
                to.http = "http://${listenAddress}:${toString yam.port}";
              }
            ];

            backup.paths = [
              (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
              (if isGuest then "/var/lib/nixos-containers/lukasl-dev${redisDir}" else redisDir)
            ];

            bindMounts = lib.mkIf isGuest [ age.secrets.${env}.path ];

            modules.yam = {
              inherit (yam) mode;
              inherit module;
            };
          };
        }

        (lib.mkIf (!isGuest) module)
      ]
    ))
  ];
}
