{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) backup;
  inherit (config.planet.hosting) mem;
  inherit (atlas.hosting.mem) host;

  listenAddress = "127.0.0.1";
  port = 8001;
  containerPort = 8000;

  stateDir = "/var/lib/honcho";
  postgresDir = "${stateDir}/postgres";
  redisDir = "${stateDir}/redis";
  ollamaDir = "${stateDir}/ollama";
  dumpDir = "${stateDir}/dump";

  postgresUid = 999;
  postgresGid = 999;
  redisUid = 999;
  redisGid = 999;

  backend = config.virtualisation.oci-containers.backend;
  network = "mem";
  networkOption = "--network=${network}";

  honchoImage = "ghcr.io/plastic-labs/honcho:v3.0.12";
  ollamaImage = "docker.io/ollama/ollama:0.32.5";

  # Embedding models cannot be swapped on a populated database without
  # re-embedding. Keep the model and schema dimension together here.
  embeddingModel = "qwen3-embedding:0.6b";
  embeddingDimensions = 1024;

  textModel = "deepseek-v4-flash";
  textBaseUrl = "https://opencode.ai/zen/go/v1";

  databasePassword = atlas.secrets.universe [
    "mem"
    "database-password"
  ];
  jwtSecret = atlas.secrets.universe [
    "mem"
    "jwt-secret"
  ];
  adminToken = atlas.secrets.universe [
    "mem"
    "admin-token"
  ];
  piToken = atlas.secrets.universe [
    "mem"
    "pi-token"
  ];
  databaseEnvironment = atlas.secrets.universe [
    "mem"
    "database-environment"
  ];
  environment = atlas.secrets.universe [
    "mem"
    "environment"
  ];
  opencodeApiKey = atlas.secrets.universe [
    "opencode"
    "apiKey"
  ];

  initSql = pkgs.writeText "honcho-init.sql" ''
    CREATE EXTENSION IF NOT EXISTS vector;
  '';

  containerServiceName = name: "${backend}-mem-${name}";
  containerService = name: "${containerServiceName name}.service";
  containerServices = map containerService [
    "api"
    "cache"
    "db"
    "deriver"
    "ollama"
  ];

  jwtGenerator =
    {
      admin ? false,
      workspace ? null,
    }:
    {
      dependencies.jwt = age.secrets.${jwtSecret};
      script =
        {
          decrypt,
          deps,
          pkgs,
          ...
        }:
        ''
          jwt_secret="$(${decrypt} "${deps.jwt.file}")"
          JWT_SECRET="$jwt_secret" ${lib.getExe pkgs.python3} <<'PY'
          import base64
          import hashlib
          import hmac
          import json
          import os

          def encode(value):
              data = json.dumps(value, separators=(",", ":")).encode()
              return base64.urlsafe_b64encode(data).rstrip(b"=").decode()

          header = encode({"alg": "HS256", "typ": "JWT"})
          payload = encode({"t": "", "ad": ${if admin then "True" else "False"}${
            lib.optionalString (workspace != null) ", \"w\": ${builtins.toJSON workspace}"
          }})
          message = f"{header}.{payload}"
          signature = hmac.new(
              os.environ["JWT_SECRET"].encode(),
              message.encode(),
              hashlib.sha256,
          ).digest()
          encoded_signature = base64.urlsafe_b64encode(signature).rstrip(b"=").decode()
          print(f"{message}.{encoded_signature}")
          PY
        '';
    };
in
{
  options.planet.hosting.mem.enable = lib.mkEnableOption "Honcho memory server";

  config = lib.mkIf mem.enable {
    age.secrets = {
      ${databasePassword} = {
        rekeyFile = ../../.. + "/secrets/${databasePassword}.age";
        generator.script = "alnum";
        intermediary = true;
      };

      ${jwtSecret} = {
        rekeyFile = ../../.. + "/secrets/${jwtSecret}.age";
        generator.script = "alnum";
        intermediary = true;
      };

      ${adminToken} = {
        rekeyFile = ../../.. + "/secrets/${adminToken}.age";
        intermediary = true;
        generator = jwtGenerator {
          admin = true;
        };
      };

      ${piToken} = {
        rekeyFile = ../../.. + "/secrets/${piToken}.age";
        generator = jwtGenerator { workspace = "pi"; };
      };

      ${databaseEnvironment} = {
        rekeyFile = ../../.. + "/secrets/${databaseEnvironment}.age";
        mode = "0400";
        generator = {
          dependencies.password = age.secrets.${databasePassword};
          script =
            { decrypt, deps, ... }:
            ''
              password="$(${decrypt} "${deps.password.file}")"
              printf 'POSTGRES_DB=honcho\n'
              printf 'POSTGRES_USER=honcho\n'
              printf 'POSTGRES_PASSWORD=%s\n' "$password"
              printf 'PGDATA=/var/lib/postgresql/data/pgdata\n'
            '';
        };
      };

      ${environment} = {
        rekeyFile = ../../.. + "/secrets/${environment}.age";
        mode = "0400";
        generator = {
          dependencies = {
            database = age.secrets.${databasePassword};
            jwt = age.secrets.${jwtSecret};
            opencode = age.secrets.${opencodeApiKey};
          };
          script =
            { decrypt, deps, ... }:
            ''
              database_password="$(${decrypt} "${deps.database.file}")"
              jwt_secret="$(${decrypt} "${deps.jwt.file}")"
              opencode_api_key="$(${decrypt} "${deps.opencode.file}")"

              cat <<EOF
              DB_CONNECTION_URI=postgresql+psycopg://honcho:$database_password@mem-db:5432/honcho
              CACHE_ENABLED=true
              CACHE_URL=redis://mem-cache:6379/0?suppress=true

              AUTH_USE_AUTH=true
              AUTH_JWT_SECRET=$jwt_secret

              LLM_OPENAI_API_KEY=$opencode_api_key
              DERIVER_MODEL_CONFIG__TRANSPORT=openai
              DERIVER_MODEL_CONFIG__MODEL=${textModel}
              DERIVER_MODEL_CONFIG__OVERRIDES__BASE_URL=${textBaseUrl}
              DERIVER_MODEL_CONFIG__STRUCTURED_OUTPUT_MODE=json_object
              SUMMARY_MODEL_CONFIG__TRANSPORT=openai
              SUMMARY_MODEL_CONFIG__MODEL=${textModel}
              SUMMARY_MODEL_CONFIG__OVERRIDES__BASE_URL=${textBaseUrl}
              DIALECTIC_LEVELS__minimal__MODEL_CONFIG__TRANSPORT=openai
              DIALECTIC_LEVELS__minimal__MODEL_CONFIG__MODEL=${textModel}
              DIALECTIC_LEVELS__minimal__MODEL_CONFIG__OVERRIDES__BASE_URL=${textBaseUrl}
              DIALECTIC_LEVELS__low__MODEL_CONFIG__TRANSPORT=openai
              DIALECTIC_LEVELS__low__MODEL_CONFIG__MODEL=${textModel}
              DIALECTIC_LEVELS__low__MODEL_CONFIG__OVERRIDES__BASE_URL=${textBaseUrl}
              DIALECTIC_LEVELS__medium__MODEL_CONFIG__TRANSPORT=openai
              DIALECTIC_LEVELS__medium__MODEL_CONFIG__MODEL=${textModel}
              DIALECTIC_LEVELS__medium__MODEL_CONFIG__OVERRIDES__BASE_URL=${textBaseUrl}
              DIALECTIC_LEVELS__high__MODEL_CONFIG__TRANSPORT=openai
              DIALECTIC_LEVELS__high__MODEL_CONFIG__MODEL=${textModel}
              DIALECTIC_LEVELS__high__MODEL_CONFIG__OVERRIDES__BASE_URL=${textBaseUrl}
              DIALECTIC_LEVELS__max__MODEL_CONFIG__TRANSPORT=openai
              DIALECTIC_LEVELS__max__MODEL_CONFIG__MODEL=${textModel}
              DIALECTIC_LEVELS__max__MODEL_CONFIG__OVERRIDES__BASE_URL=${textBaseUrl}
              DREAM_DEDUCTION_MODEL_CONFIG__TRANSPORT=openai
              DREAM_DEDUCTION_MODEL_CONFIG__MODEL=${textModel}
              DREAM_DEDUCTION_MODEL_CONFIG__OVERRIDES__BASE_URL=${textBaseUrl}
              DREAM_INDUCTION_MODEL_CONFIG__TRANSPORT=openai
              DREAM_INDUCTION_MODEL_CONFIG__MODEL=${textModel}
              DREAM_INDUCTION_MODEL_CONFIG__OVERRIDES__BASE_URL=${textBaseUrl}

              OLLAMA_API_KEY=ollama
              EMBEDDING_VECTOR_DIMENSIONS=${toString embeddingDimensions}
              EMBEDDING_MODEL_CONFIG__TRANSPORT=openai
              EMBEDDING_MODEL_CONFIG__MODEL=${embeddingModel}
              EMBEDDING_MODEL_CONFIG__DIMENSIONS_MODE=always
              EMBEDDING_MODEL_CONFIG__OVERRIDES__BASE_URL=http://mem-ollama:11434/v1
              EMBEDDING_MODEL_CONFIG__OVERRIDES__API_KEY_ENV=OLLAMA_API_KEY

              LOG_LEVEL=INFO
              METRICS_ENABLED=false
              SENTRY_ENABLED=false
              EOF
            '';
        };
      };
    };

    virtualisation.oci-containers.containers = {
      mem-db = {
        image = "docker.io/pgvector/pgvector:pg15";
        cmd = [
          "postgres"
          "-c"
          "max_connections=200"
        ];
        environmentFiles = [ age.secrets.${databaseEnvironment}.path ];
        volumes = [
          "${initSql}:/docker-entrypoint-initdb.d/init.sql:ro"
          "${postgresDir}:/var/lib/postgresql/data"
        ];
        extraOptions = [
          networkOption
          "--network-alias=mem-db"
        ];
      };

      mem-cache = {
        image = "docker.io/redis:8.2";
        cmd = [
          "redis-server"
          "--save"
          "300"
          "10"
          "--maxmemory-policy"
          "volatile-lru"
        ];
        volumes = [ "${redisDir}:/data" ];
        extraOptions = [
          networkOption
          "--network-alias=mem-cache"
        ];
      };

      mem-ollama = {
        image = ollamaImage;
        volumes = [ "${ollamaDir}:/root/.ollama" ];
        extraOptions = [
          networkOption
          "--network-alias=mem-ollama"
        ];
      };

      mem-api = {
        image = honchoImage;
        entrypoint = "/bin/sh";
        cmd = [
          "-c"
          ''
            python scripts/provision_db.py \
              && python scripts/configure_embeddings.py --yes \
              && exec fastapi run --host 0.0.0.0 src/main.py
          ''
        ];
        environmentFiles = [ age.secrets.${environment}.path ];
        ports = [
          "${listenAddress}:${toString port}:${toString containerPort}"
        ];
        dependsOn = [
          "mem-cache"
          "mem-db"
          "mem-ollama"
        ];
        extraOptions = [
          networkOption
          "--network-alias=mem-api"
        ];
      };

      mem-deriver = {
        image = honchoImage;
        entrypoint = "/app/.venv/bin/python";
        cmd = [
          "-m"
          "src.deriver"
        ];
        environmentFiles = [ age.secrets.${environment}.path ];
        dependsOn = [
          "mem-api"
          "mem-cache"
          "mem-db"
          "mem-ollama"
        ];
        extraOptions = [ networkOption ];
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d ${stateDir} 0750 root root -"
        "d ${postgresDir} 0700 ${toString postgresUid} ${toString postgresGid} -"
        "d ${redisDir} 0750 ${toString redisUid} ${toString redisGid} -"
        "d ${ollamaDir} 0750 root root -"
        "d ${dumpDir} 0700 root root -"
      ];

      services = {
        create-mem-network = {
          description = "Create Docker network for Honcho";
          after = [ "docker.service" ];
          requires = [ "docker.service" ];
          wantedBy = containerServices;
          before = containerServices;

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

        mem-ollama-model = {
          description = "Pull the Honcho embedding model";
          after = [ (containerService "ollama") ];
          requires = [ (containerService "ollama") ];
          before = [ "mem-infrastructure-ready.service" ];
          path = [ pkgs.coreutils ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            set -euo pipefail
            for _ in $(seq 1 60); do
              if ${lib.getExe pkgs.docker} exec mem-ollama ollama list \
                >/dev/null 2>&1; then
                exec ${lib.getExe pkgs.docker} exec mem-ollama \
                  ollama pull ${lib.escapeShellArg embeddingModel}
              fi
              sleep 2
            done
            echo "Ollama did not become ready" >&2
            exit 1
          '';
        };

        mem-infrastructure-ready = {
          description = "Wait for the Honcho database, cache, and embeddings";
          after = [
            (containerService "cache")
            (containerService "db")
            "mem-ollama-model.service"
          ];
          requires = [
            (containerService "cache")
            (containerService "db")
            "mem-ollama-model.service"
          ];
          before = [ (containerService "api") ];
          path = [
            pkgs.coreutils
            pkgs.gnugrep
          ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            set -euo pipefail
            for _ in $(seq 1 60); do
              if ${lib.getExe pkgs.docker} exec mem-db \
                pg_isready -U honcho -d honcho >/dev/null 2>&1 \
                && ${lib.getExe pkgs.docker} exec mem-cache \
                redis-cli ping 2>/dev/null | grep -qx PONG; then
                exit 0
              fi
              sleep 2
            done
            echo "Honcho infrastructure did not become ready" >&2
            exit 1
          '';
        };

        mem-api-ready = {
          description = "Wait for the Honcho API";
          after = [ (containerService "api") ];
          requires = [ (containerService "api") ];
          before = [ (containerService "deriver") ];
          path = [ pkgs.coreutils ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            set -euo pipefail
            for _ in $(seq 1 60); do
              if ${lib.getExe pkgs.curl} --fail --silent \
                http://${listenAddress}:${toString port}/health >/dev/null; then
                exit 0
              fi
              sleep 2
            done
            echo "Honcho API did not become ready" >&2
            exit 1
          '';
        };

        ${containerServiceName "api"} = {
          after = [ "mem-infrastructure-ready.service" ];
          requires = [ "mem-infrastructure-ready.service" ];
        };

        ${containerServiceName "deriver"} = {
          after = [ "mem-api-ready.service" ];
          requires = [ "mem-api-ready.service" ];
        };
      };
    };

    # TODO: for later
    # services.restic.backups.${config.planet.name}.backupPrepareCommand =
    #   lib.mkIf backup.enable ''
    #     set -euo pipefail
    #     temporary=${dumpDir}/honcho.sql.tmp
    #     ${lib.getExe pkgs.docker} exec mem-db \
    #       pg_dump --clean --if-exists -U honcho -d honcho >"$temporary"
    #     mv "$temporary" ${dumpDir}/honcho.sql
    #   '';

    planet = {
      # backup.dirs = [ dumpDir ];

      hosting.proxy.rules.mem = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
