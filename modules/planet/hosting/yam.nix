{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet.hosting) yam;
  inherit (atlas.hosting.yam) host;

  listenAddress = "127.0.0.1";
  port = 5772;
  containerPort = 8000;

  stateDir = "/var/lib/yamtrack";
  redisDir = "/var/lib/yamtrack-redis";

  yamtrackUid = 1000;
  yamtrackGid = 1000;
  redisUid = 999;
  redisGid = 1000;

  backend = config.virtualisation.oci-containers.backend;
  network = "yamtrack";

  secret = atlas.secrets.universe [
    "yam"
    "secret"
  ];
  env = atlas.secrets.universe [
    "yam"
    "env"
  ];
in
{
  options.planet.hosting.yam.enable = lib.mkEnableOption "Yamtrack server";

  config = lib.mkIf yam.enable {
    age.secrets = {
      ${secret} = {
        rekeyFile = ../../.. + "/secrets/${secret}.age";
        intermediary = true;
      };

      ${env} = {
        rekeyFile = ../../.. + "/secrets/${env}.age";
        mode = "0400";
        generator = {
          dependencies.secret = age.secrets.${secret};
          script =
            { decrypt, deps, ... }:
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

    virtualisation.oci-containers.containers = {
      yamtrack = {
        image = "ghcr.io/fuzzygrim/yamtrack:latest";
        ports = [
          "${listenAddress}:${toString port}:${toString containerPort}"
        ];
        environment = {
          TZ = "Europe/Berlin";
          PUID = toString yamtrackUid;
          PGID = toString yamtrackGid;
          REDIS_URL = "redis://yamtrack-redis:6379";
          URLS = "https://${host}";
          REGISTRATION = "False";
        };
        environmentFiles = [ age.secrets.${env}.path ];
        volumes = [ "${stateDir}:/yamtrack/db" ];
        dependsOn = [ "yamtrack-redis" ];
        extraOptions = [ "--network=${network}" ];
      };

      yamtrack-redis = {
        image = "redis:8-alpine";
        volumes = [ "${redisDir}:/data" ];
        extraOptions = [
          "--network=${network}"
          "--network-alias=yamtrack-redis"
        ];
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d ${stateDir} 0750 ${toString yamtrackUid} ${toString yamtrackGid} -"
        "d ${redisDir} 0750 ${toString redisUid} ${toString redisGid} -"
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
        script = ''
          ${lib.getExe pkgs.docker} network inspect ${network} \
            >/dev/null 2>&1 \
            || ${lib.getExe pkgs.docker} network create ${network}
        '';
      };
    };

    planet = {
      backup.dirs = [
        stateDir
        redisDir
      ];

      hosting.proxy.rules.yam = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
