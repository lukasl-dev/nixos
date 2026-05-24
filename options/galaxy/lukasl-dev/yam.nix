{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) domain addresses yam;

  inherit (config.virtualisation.oci-containers) backend;
in
{
  options.galaxy.lukasl-dev = {
    yam = {
      enable = lib.mkEnableOption "Enable yamtrack server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 5772;
        readOnly = true;
        description = "Port for the yamtrack server.";
      };

      stateDir = lib.mkOption {
        type = lib.types.port;
        default = "/var/lib/yamtrack";
        readOnly = true;
      };

      redisDir = lib.mkOption {
        type = lib.types.port;
        default = "/var/lib/yamtrack-redis";
        readOnly = true;
      };
    };
  };

  config = lib.mkIf yam.enable (
    let
      secret = "galaxy/lukasl-dev/yam/secret";
      env = "galaxy/lukasl-dev/yam/env";
    in
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

      galaxy.lukasl-dev = {
        proxy.rules = [
          {
            type = "https";
            name = "yam";
            to.http = "http://${addresses.local}:${toString yam.port}";
          }
        ];

        bindMounts = [ age.secrets.${env}.path ];

        modules = [
          {
            virtualisation.oci-containers.containers = {
              yamtrack = {
                image = "ghcr.io/fuzzygrim/yamtrack:latest";
                ports = [ "${toString yam.port}:8000" ];
                environment = {
                  TZ = "Europe/Berlin";
                  REDIS_URL = "redis://yamtrack-redis:6379";
                  URLS = "https://yam.${domain}";
                  REGISTRATION = "False";
                };
                environmentFiles = [ templates."planets/pollux/yamtrack/env".path ];
                volumes = [ "${yam.stateDir}:/yamtrack/db" ];
                dependsOn = [ "yamtrack-redis" ];
                extraOptions = [ "--network=yamtrack" ];
              };

              yamtrack-redis = {
                image = "redis:8-alpine";
                volumes = [ "${yam.redisDir}:/data" ];
                extraOptions = [
                  "--network=yamtrack"
                  "--network-alias=yamtrack-redis"
                ];
              };
            };

            networking.firewall.allowedTCPPorts = [ yam.port ];

            systemd = {
              tmpfiles.rules = [
                "d ${yam.stateDir} 0750 root root -"
                "d ${yam.redisDir} 0750 root root -"
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
          }
        ];
      };

    }
  );
}
