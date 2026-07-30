{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet.hosting) fit;
  inherit (atlas.hosting.fit) host;

  listenAddress = "127.0.0.1";
  port = 8743;
  appPort = 8744;
  containerPort = 8000;

  stateDir = "/var/lib/wger";
  mediaDir = "${stateDir}/media";
  staticDir = "${stateDir}/static";
  postgresDir = "${stateDir}/postgres";
  redisDir = "${stateDir}/redis";
  beatDir = "${stateDir}/beat";

  wgerUid = 1000;
  wgerGid = 1000;
  postgresUid = 70;
  postgresGid = 70;
  redisUid = 999;
  redisGid = 1000;

  backend = config.virtualisation.oci-containers.backend;
  network = "fit";

  secretKey = atlas.secrets.universe [
    "fit"
    "secret-key"
  ];
  databasePassword = atlas.secrets.universe [
    "fit"
    "database-password"
  ];
  jwtKeys = atlas.secrets.universe [
    "fit"
    "jwt-keys"
  ];
  environment = atlas.secrets.universe [
    "fit"
    "environment"
  ];

  environmentFiles = [ age.secrets.${environment}.path ];
  networkOption = "--network=${network}";
in
{
  options.planet.hosting.fit.enable = lib.mkEnableOption "wger fitness server";

  config = lib.mkIf fit.enable {
    age.secrets = {
      ${secretKey} = {
        rekeyFile = ../../.. + "/secrets/${secretKey}.age";
        generator.script = "alnum";
        intermediary = true;
      };

      ${databasePassword} = {
        rekeyFile = ../../.. + "/secrets/${databasePassword}.age";
        generator.script = "alnum";
        intermediary = true;
      };

      ${jwtKeys} = {
        rekeyFile = ../../.. + "/secrets/${jwtKeys}.age";
        intermediary = true;
        generator.script =
          { pkgs, ... }:
          let
            python = pkgs.python3.withPackages (ps: [
              ps.cryptography
              ps.pyjwt
            ]);
          in
          ''
            ${lib.getExe python} <<'PY'
            import json
            from base64 import urlsafe_b64encode

            from cryptography.hazmat.primitives.asymmetric import rsa
            from jwt.algorithms import RSAAlgorithm


            key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
            private = json.loads(RSAAlgorithm.to_jwk(key))
            private.update(alg="RS256", kid="wger")
            public = {name: private[name] for name in ("kty", "n", "e", "alg", "kid")}


            def encode(value):
                data = json.dumps(value, separators=(",", ":")).encode()
                return urlsafe_b64encode(data).decode()


            print(f"JWT_PRIVATE_KEY={encode(private)}")
            print(f"JWT_PUBLIC_KEY={encode(public)}")
            PY
          '';
      };

      ${environment} = {
        rekeyFile = ../../.. + "/secrets/${environment}.age";
        mode = "0400";
        generator = {
          dependencies = {
            databasePassword = age.secrets.${databasePassword};
            jwtKeys = age.secrets.${jwtKeys};
            secretKey = age.secrets.${secretKey};
          };
          script =
            { decrypt, deps, ... }:
            ''
              database_password="$(${decrypt} "${deps.databasePassword.file}")"
              secret_key="$(${decrypt} "${deps.secretKey.file}")"

              cat <<EOF
              SECRET_KEY=$secret_key
              SITE_URL=https://${host}
              TIME_ZONE=Europe/Berlin
              TZ=Europe/Berlin

              ALLOW_REGISTRATION=False
              ALLOW_GUEST_USERS=False
              ALLOW_UPLOAD_VIDEOS=True
              WGER_INSTANCE=https://wger.de

              SYNC_EXERCISES_CELERY=True
              SYNC_EXERCISE_IMAGES_CELERY=True
              SYNC_EXERCISE_VIDEOS_CELERY=True
              SYNC_INGREDIENTS_CELERY=True
              SYNC_INGREDIENTS_DUMP_URL=https://wger.de/media/ingredients/ingredients.jsonl.gz
              DOWNLOAD_INGREDIENTS_FROM=WGER
              CACHE_API_EXERCISES_CELERY=True
              CACHE_API_EXERCISES_CELERY_FORCE_UPDATE=True

              USE_CELERY=True
              CELERY_BROKER=redis://fit-cache:6379/2
              CELERY_BACKEND=redis://fit-cache:6379/2
              CELERY_WORKER_CONCURRENCY=4

              POSTGRES_USER=wger
              POSTGRES_PASSWORD=$database_password
              POSTGRES_DB=wger
              PS_DATABASE_URI=postgres://wger:$database_password@fit-db:5432/wger
              DJANGO_PERFORM_MIGRATIONS=True

              DJANGO_CACHE_BACKEND=django_redis.cache.RedisCache
              DJANGO_CACHE_LOCATION=redis://fit-cache:6379/1
              DJANGO_CACHE_TIMEOUT=1296000
              DJANGO_CACHE_CLIENT_CLASS=django_redis.client.DefaultClient

              AXES_ENABLED=True
              AXES_FAILURE_LIMIT=10
              AXES_COOLOFF_TIME=30
              AXES_HANDLER=axes.handlers.cache.AxesCacheHandler
              AXES_LOCKOUT_PARAMETERS=ip_address
              AXES_IPWARE_PROXY_COUNT=2

              DJANGO_DEBUG=False
              WGER_USE_GUNICORN=True
              WGER_PORT=${toString containerPort}
              X_FORWARDED_PROTO_HEADER_SET=True
              USE_X_FORWARDED_HOST=True
              CSRF_TRUSTED_ORIGINS=https://${host}
              NUMBER_OF_PROXIES=2
              EOF

              ${decrypt} "${deps.jwtKeys.file}"
            '';
        };
      };
    };

    virtualisation.oci-containers.containers = {
      fit-db = {
        image = "docker.io/postgres:15-alpine";
        inherit environmentFiles;
        volumes = [ "${postgresDir}:/var/lib/postgresql/data" ];
        extraOptions = [
          networkOption
          "--network-alias=fit-db"
        ];
      };

      fit-cache = {
        image = "docker.io/redis:8-alpine";
        cmd = [
          "redis-server"
          "--save"
          "3600"
          "1"
          "300"
          "100"
          "60"
          "10000"
          "--maxmemory-policy"
          "volatile-lru"
        ];
        volumes = [ "${redisDir}:/data" ];
        extraOptions = [
          networkOption
          "--network-alias=fit-cache"
        ];
      };

      fit-web = {
        image = "docker.io/wger/server:latest";
        inherit environmentFiles;
        ports = [
          "${listenAddress}:${toString appPort}:${toString containerPort}"
        ];
        volumes = [
          "${mediaDir}:/home/wger/media"
          "${staticDir}:/home/wger/static"
        ];
        dependsOn = [
          "fit-db"
          "fit-cache"
        ];
        extraOptions = [
          networkOption
          "--network-alias=fit-web"
        ];
      };

      fit-celery-worker = {
        image = "docker.io/wger/server:latest";
        cmd = [ "/start-worker" ];
        inherit environmentFiles;
        volumes = [ "${mediaDir}:/home/wger/media" ];
        dependsOn = [
          "fit-db"
          "fit-cache"
          "fit-web"
        ];
        extraOptions = [ networkOption ];
      };

      fit-celery-beat = {
        image = "docker.io/wger/server:latest";
        cmd = [ "/start-beat" ];
        inherit environmentFiles;
        volumes = [ "${beatDir}:/home/wger/beat" ];
        dependsOn = [
          "fit-cache"
          "fit-celery-worker"
          "fit-db"
        ];
        extraOptions = [ networkOption ];
      };
    };

    services.nginx = {
      enable = true;

      virtualHosts.${host} = {
        listen = [
          {
            addr = listenAddress;
            inherit port;
          }
        ];

        locations = {
          "/" = {
            proxyPass = "http://${listenAddress}:${toString appPort}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $http_host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-Host $http_host;
              proxy_read_timeout 86400s;
              proxy_send_timeout 86400s;
              client_max_body_size 100M;
            '';
          };

          "/static/" = {
            alias = "${staticDir}/";
            extraConfig = ''
              add_header Cache-Control "public, max-age=31536000, immutable" always;
              add_header Vary "Accept-Encoding" always;
            '';
          };

          "/media/".alias = "${mediaDir}/";
        };
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d ${stateDir} 0755 root root -"
        "d ${mediaDir} 0755 ${toString wgerUid} ${toString wgerGid} -"
        "d ${staticDir} 0755 ${toString wgerUid} ${toString wgerGid} -"
        "d ${postgresDir} 0700 ${toString postgresUid} ${toString postgresGid} -"
        "d ${redisDir} 0750 ${toString redisUid} ${toString redisGid} -"
        "d ${beatDir} 0750 ${toString wgerUid} ${toString wgerGid} -"
      ];

      services.create-fit-network = {
        description = "Create Docker network for wger";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        wantedBy = [
          "${backend}-fit-db.service"
          "${backend}-fit-cache.service"
          "${backend}-fit-web.service"
          "${backend}-fit-celery-worker.service"
          "${backend}-fit-celery-beat.service"
        ];
        before = [
          "${backend}-fit-db.service"
          "${backend}-fit-cache.service"
          "${backend}-fit-web.service"
          "${backend}-fit-celery-worker.service"
          "${backend}-fit-celery-beat.service"
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
        mediaDir
        postgresDir
        beatDir
      ];

      hosting.proxy.rules.fit = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
