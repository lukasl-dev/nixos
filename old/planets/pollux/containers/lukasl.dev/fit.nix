{ config, pkgs, ... }:

let
  meta = import ./meta.nix;

  sub = "fit";
  host = "${sub}.${meta.domain}";
  port = 3812;
  webPort = 8000;

  network = "fit-wger";
  prefix = "fit-wger";

  dataDir = "/var/lib/wger";
  staticDir = "${dataDir}/static";
  mediaDir = "${dataDir}/media";
  beatDir = "${dataDir}/beat";

  secret = path: "planets/pollux/lukasl.dev/fit/${path}";
  envFile = config.age.secrets.${secret "env"}.path;

  images = {
    server = pkgs.dockerTools.pullImage {
      imageName = "wger/server";
      imageDigest = "sha256:d61c8a5b5821c45203656406acd35ffa9b1a6e5ad5315d775e7fd4d7bc90fd22";
      hash = "sha256-iK/kBIDiIlVFB2UaRaYBjKn7MjJj/OCVxgb73yRhHkw=";
      finalImageName = "wger/server";
      finalImageTag = "latest";
    };

    postgres = pkgs.dockerTools.pullImage {
      imageName = "postgres";
      imageDigest = "sha256:1c52f5ad23db5d7648a63634444af76de48e63b860fccbe3e3a5458b2812eaed";
      hash = "sha256-Fvvv53+q/7gy8PhAmaU/Fapj/LkSaKftG/SEa9fgOF0=";
      finalImageName = "postgres";
      finalImageTag = "15-alpine";
    };

    redis = pkgs.dockerTools.pullImage {
      imageName = "redis";
      imageDigest = "sha256:6cbef353e480a8a6e7f10ec545f13d7d3fa85a212cdcc5ffaf5a1c818b9d3798";
      hash = "sha256-YXxc4moujLHOE2JIpCxfS1Dh4EByk/f6Rp7hzemnc4Y=";
      finalImageName = "redis";
      finalImageTag = "8-alpine";
    };
  };

  redisConf = pkgs.writeText "fit-wger-redis.conf" ''
    bind * -::*
    protected-mode no
    dir /data
    save 3600 1 300 100 60 10000
  '';

  containerNames = [
    "${prefix}-web"
    "${prefix}-db"
    "${prefix}-cache"
    "${prefix}-worker"
    "${prefix}-beat"
  ];
in
{
  age.secrets = {
    ${secret "secret_key"} = {
      rekeyFile = ../../../../secrets/${secret "secret_key"}.age;
      generator.script = "alnum";
    };

    ${secret "signing_key"} = {
      rekeyFile = ../../../../secrets/${secret "signing_key"}.age;
      generator.script = "alnum";
    };

    ${secret "db_password"} = {
      rekeyFile = ../../../../secrets/${secret "db_password"}.age;
      generator.script = "alnum";
    };

    ${secret "env"} = {
      rekeyFile = ../../../../secrets/${secret "env"}.age;
      mode = "0400";
      generator = {
        dependencies = {
          secretKey = config.age.secrets.${secret "secret_key"};
          signingKey = config.age.secrets.${secret "signing_key"};
          dbPassword = config.age.secrets.${secret "db_password"};
        };
        script =
          { decrypt, deps, ... }:
          ''
            secret_key="$(${decrypt} "${deps.secretKey.file}")"
            signing_key="$(${decrypt} "${deps.signingKey.file}")"
            db_password="$(${decrypt} "${deps.dbPassword.file}")"

            cat <<EOF
            SECRET_KEY=$secret_key
            SIGNING_KEY=$signing_key
            POSTGRES_USER=wger
            POSTGRES_PASSWORD=$db_password
            POSTGRES_DB=wger
            TIME_ZONE=Europe/Berlin
            TZ=Europe/Berlin
            SITE_URL=https://${host}
            CSRF_TRUSTED_ORIGINS=https://${host}
            X_FORWARDED_PROTO_HEADER_SET=True
            ALLOW_REGISTRATION=False
            ALLOW_GUEST_USERS=False
            DJANGO_DEBUG=False
            DJANGO_CLEAR_STATIC_FIRST=False
            DJANGO_COLLECTSTATIC_ON_STARTUP=True
            DJANGO_DB_ENGINE=django.db.backends.postgresql
            DJANGO_DB_DATABASE=wger
            DJANGO_DB_USER=wger
            DJANGO_DB_PASSWORD=$db_password
            DJANGO_DB_HOST=db
            DJANGO_DB_PORT=5432
            DJANGO_PERFORM_MIGRATIONS=True
            DJANGO_CACHE_BACKEND=django_redis.cache.RedisCache
            DJANGO_CACHE_LOCATION=redis://cache:6379/1
            DJANGO_CACHE_TIMEOUT=1296000
            DJANGO_CACHE_CLIENT_CLASS=django_redis.client.DefaultClient
            CELERY_BROKER=redis://cache:6379/2
            CELERY_BACKEND=redis://cache:6379/2
            USE_CELERY=True
            WGER_USE_GUNICORN=True
            WGER_PORT=8000
            NUMBER_OF_PROXIES=2
            AXES_IPWARE_PROXY_COUNT=2
            EOF
          '';
      };
    };
  };

  pollux.containers.${meta.container} = [
    (
      { config, pkgs, lib, ... }:
      let
        inherit (config.virtualisation.oci-containers) backend;
        inherit (config.sops) templates placeholder;

        mkNetworkedContainer = image: imageFile: extra:
          (builtins.removeAttrs extra [ "extraOptions" ])
          // {
            inherit image imageFile;
            extraOptions = [ "--network=${network}" ] ++ (extra.extraOptions or [ ]);
          };

        mkWgerContainer = extra:
          mkNetworkedContainer "wger/server:latest" images.server (
            {
              environmentFiles = [
                envFile
                templates."planets/pollux/wger/mail-env".path
              ];
              environment = {
                DJANGO_DEBUG = "False";
                DJANGO_CLEAR_STATIC_FIRST = "False";
                DJANGO_COLLECTSTATIC_ON_STARTUP = "True";
                ENABLE_EMAIL = "True";
                EMAIL_HOST = "mail.${meta.domain}";
                EMAIL_PORT = "587";
                EMAIL_HOST_USER = "bot@${meta.domain}";
                EMAIL_USE_TLS = "True";
                FROM_EMAIL = "wger Workout Manager <bot@${meta.domain}>";
              };
            }
            // extra
          );
      in
      {
        virtualisation.oci-containers.containers = {
          "${prefix}-web" = mkWgerContainer {
            ports = [ "127.0.0.1:${toString webPort}:8000" ];
            volumes = [
              "${staticDir}:/home/wger/static"
              "${mediaDir}:/home/wger/media"
            ];
            dependsOn = [
              "${prefix}-db"
              "${prefix}-cache"
            ];
            extraOptions = [ "--network-alias=web" ];
          };

          "${prefix}-db" = mkNetworkedContainer "postgres:15-alpine" images.postgres {
            environmentFiles = [ envFile ];
            volumes = [ "${prefix}-postgres:/var/lib/postgresql/data" ];
            extraOptions = [ "--network-alias=db" ];
          };

          "${prefix}-cache" = mkNetworkedContainer "redis:8-alpine" images.redis {
            cmd = [
              "redis-server"
              "/usr/local/etc/redis/redis.conf"
            ];
            volumes = [
              "${redisConf}:/usr/local/etc/redis/redis.conf:ro"
              "${prefix}-redis:/data"
            ];
            extraOptions = [ "--network-alias=cache" ];
          };

          "${prefix}-worker" = mkWgerContainer {
            cmd = [ "/start-worker" ];
            volumes = [ "${mediaDir}:/home/wger/media" ];
            dependsOn = [ "${prefix}-web" ];
          };

          "${prefix}-beat" = mkWgerContainer {
            cmd = [ "/start-beat" ];
            volumes = [ "${beatDir}:/home/wger/beat" ];
            dependsOn = [ "${prefix}-worker" ];
          };
        };

        sops = {
          secrets."planets/pollux/maddy/bot" = lib.mkDefault { };

          templates."planets/pollux/wger/mail-env" = {
            content = ''
              EMAIL_HOST_PASSWORD=${placeholder."planets/pollux/maddy/bot"}
            '';
          };
        };

        systemd.tmpfiles.rules = [
          "d ${dataDir} 0755 root root -"
          "d ${staticDir} 0755 1000 1000 -"
          "d ${mediaDir} 0755 1000 1000 -"
          "d ${beatDir} 0755 1000 1000 -"
        ];

        services.nginx = {
          enable = true;
          commonHttpConfig = ''
            map $http_x_forwarded_proto $final_forwarded_proto {
                default $http_x_forwarded_proto;
                '''      $scheme;
            }
          '';
          virtualHosts.${host} = {
            listen = [
              {
                addr = meta.address.local;
                inherit port;
              }
            ];
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString webPort}";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $final_forwarded_proto;
                proxy_set_header X-Forwarded-Host $host;

                proxy_redirect off;
                proxy_read_timeout 86400s;
                proxy_send_timeout 86400s;
              '';
            };
            locations."/static/".extraConfig = ''
              alias ${staticDir}/;
              add_header Cache-Control "public, max-age=31536000, immutable" always;
              add_header Vary "Accept-Encoding" always;
            '';
            locations."/media/".extraConfig = ''
              alias ${mediaDir}/;
            '';
            extraConfig = ''
              client_max_body_size 100M;
            '';
          };
        };

        networking.firewall.allowedTCPPorts = [ port ];

        systemd.services.nginx.after = [ "${backend}-${prefix}-web.service" ];
        systemd.services.nginx.wants = [ "${backend}-${prefix}-web.service" ];

        systemd.services.create-fit-wger-network = {
          description = "Create Docker network for fit.lukasl.dev";
          after = [ "docker.service" ];
          requires = [ "docker.service" ];
          wantedBy = builtins.map (name: "${backend}-${name}.service") containerNames;
          before = builtins.map (name: "${backend}-${name}.service") containerNames;

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            ${pkgs.docker}/bin/docker network inspect ${network} >/dev/null 2>&1 \
              || ${pkgs.docker}/bin/docker network create ${network}
          '';
        };
      }
    )
  ];

  containers.${meta.container} = {
    bindMounts.${envFile} = {
      hostPath = envFile;
      isReadOnly = true;
    };
  };

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
        loadBalancer = {
          passHostHeader = true;
          servers = [
            {
              url = "http://${meta.address.local}:${toString port}";
            }
          ];
        };
      };
    };
}
