{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy) domain mail todo;
  inherit (config.planet) name;
  inherit (todo) sync;

  listenAddress = "127.0.0.1";
  backend = "docker";

  networkName = "super-productivity-sync";
  containerName = "super-productivity-sync";
  databaseContainerName = "${containerName}-postgres";

  containerUnit = "${backend}-${containerName}.service";
  databaseContainerUnit = "${backend}-${databaseContainerName}.service";
  waitForDatabaseUnit = "${containerName}-wait-for-database.service";
  databaseBackupUnit = "${containerName}-backup.service";

  stateDir = "/var/lib/${containerName}";
  databaseDir = "/var/lib/${databaseContainerName}";
  backupDir = "/var/backup/${containerName}";

  databasePassword = "galaxy/todo/sync/databasePassword";
  jwtSecret = "galaxy/todo/sync/jwtSecret";
  databaseEnvironment = "galaxy/todo/sync/databaseEnvironment";
  syncEnvironment = "galaxy/todo/sync/environment";
in
{
  options.galaxy.todo.sync = {
    enable = lib.mkEnableOption "Enable the SuperSync server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 1900;
      readOnly = true;
      description = "Port for the SuperSync server.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "sync.todo.${domain}";
      readOnly = true;
      description = "Public hostname for the SuperSync server.";
    };

    image = lib.mkOption {
      type = lib.types.str;
      # The official image is private. This public image is built unchanged
      # from the corresponding official Super Productivity release source.
      default = "ghcr.io/warreth/super-sync-server:v18.14.0@sha256:78a8e7f47e1e475e8265a6feb505082fc364a8d507492c8478325043ccb7945e";
      description = "OCI image used for the SuperSync server.";
    };
  };

  config = lib.mkMerge [
    {
      age.secrets = {
        ${databasePassword} = {
          rekeyFile = ../../../secrets/galaxy/todo/sync/databasePassword.age;
          generator.script = "alnum";
          intermediary = true;
        };

        ${jwtSecret} = {
          rekeyFile = ../../../secrets/galaxy/todo/sync/jwtSecret.age;
          generator.script = "base64";
          intermediary = true;
        };

        ${databaseEnvironment} = {
          rekeyFile = ../../../secrets/galaxy/todo/sync/databaseEnvironment.age;
          generator = {
            dependencies.databasePassword = age.secrets.${databasePassword};
            script =
              { decrypt, deps, ... }:
              ''
                databasePassword="$(${decrypt} ${lib.escapeShellArg deps.databasePassword.file})"
                printf 'POSTGRES_PASSWORD=%s\n' "$databasePassword"
              '';
          };
        };

        ${syncEnvironment} = {
          rekeyFile = ../../../secrets/galaxy/todo/sync/environment.age;
          generator = {
            dependencies = {
              databasePassword = age.secrets.${databasePassword};
              jwtSecret = age.secrets.${jwtSecret};
              smtpPassword = age.secrets.${mail.accounts.bot};
            };
            script =
              { decrypt, deps, ... }:
              ''
                databasePassword="$(${decrypt} ${lib.escapeShellArg deps.databasePassword.file})"
                jwtSecret="$(${decrypt} ${lib.escapeShellArg deps.jwtSecret.file})"
                smtpPassword="$(${decrypt} ${lib.escapeShellArg deps.smtpPassword.file})"

                printf 'DATABASE_URL=postgresql://supersync:%s@postgres:5432/supersync?connection_limit=20&pool_timeout=20\n' "$databasePassword"
                printf 'JWT_SECRET=%s\n' "$jwtSecret"
                printf 'SMTP_PASS=%s\n' "$smtpPassword"
              '';
          };
        };
      };
    }

    (lib.mkIf sync.enable {
      assertions = [
        {
          assertion = todo.enable;
          message = "galaxy.todo.enable must be enabled when galaxy.todo.sync.enable is enabled.";
        }
        {
          assertion = mail.enable;
          message = "galaxy.mail.enable must be enabled for SuperSync email verification.";
        }
      ];

      virtualisation = {
        docker.enable = true;
        oci-containers = {
          inherit backend;

          containers = {
            ${containerName} = {
              inherit (sync) image;
              ports = [ "${listenAddress}:${toString sync.port}:1900" ];
              environment = {
                NODE_ENV = "production";
                PORT = "1900";
                HOST = "0.0.0.0";
                DATA_DIR = "/app/data";
                RUN_MIGRATIONS_ON_STARTUP = "true";
                PUBLIC_URL = "https://${sync.host}";
                CORS_ORIGINS = "https://todo.${domain}";
                ALLOWED_EMAILS = "*@${domain}";
                SMTP_HOST = mail.host;
                SMTP_PORT = "587";
                SMTP_SECURE = "false";
                SMTP_USER = "bot@${domain}";
                SMTP_FROM = "Super Productivity <bot@${domain}>";
                WEBAUTHN_RP_ID = sync.host;
                WEBAUTHN_RP_NAME = "Super Productivity Sync";
                WEBAUTHN_ORIGIN = "https://${sync.host}";
              };
              environmentFiles = [ age.secrets.${syncEnvironment}.path ];
              volumes = [ "${stateDir}:/app/data" ];
              dependsOn = [ databaseContainerName ];
              extraOptions = [
                "--network=${networkName}"
                "--memory=768m"
                "--cpus=1.0"
                "--ulimit=nofile=65535:65535"
                "--security-opt=no-new-privileges"
                "--cap-drop=ALL"
              ];
            };

            ${databaseContainerName} = {
              image = "postgres:16-alpine";
              environment = {
                POSTGRES_USER = "supersync";
                POSTGRES_DB = "supersync";
              };
              environmentFiles = [ age.secrets.${databaseEnvironment}.path ];
              volumes = [ "${databaseDir}:/var/lib/postgresql/data" ];
              cmd = [
                "postgres"
                "-c"
                "shared_buffers=384MB"
                "-c"
                "effective_cache_size=1GB"
                "-c"
                "work_mem=4MB"
                "-c"
                "maintenance_work_mem=128MB"
                "-c"
                "max_connections=120"
                "-c"
                "random_page_cost=1.1"
                "-c"
                "idle_in_transaction_session_timeout=300000"
                "-c"
                "wal_compression=on"
                "-c"
                "huge_pages=off"
              ];
              extraOptions = [
                "--network=${networkName}"
                "--network-alias=postgres"
                "--memory=1536m"
                "--shm-size=256m"
                "--security-opt=no-new-privileges"
              ];
            };
          };
        };
      };

      systemd = {
        tmpfiles.rules = [
          "d ${stateDir} 0750 1001 1001 - -"
          # postgres:16-alpine runs as uid/gid 70 after initialization.
          "d ${databaseDir} 0700 70 70 - -"
          "d ${backupDir} 0700 root root - -"
        ];

        services = {
          "create-${networkName}-network" = {
            description = "Create the SuperSync Docker network";
            before = [
              containerUnit
              databaseContainerUnit
            ];
            requiredBy = [
              containerUnit
              databaseContainerUnit
            ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              ${lib.getExe pkgs.docker} network inspect ${networkName} >/dev/null 2>&1 \
                || ${lib.getExe pkgs.docker} network create ${networkName}
            '';
          };

          "${containerName}-wait-for-database" = {
            description = "Wait for the SuperSync PostgreSQL database";
            requires = [ databaseContainerUnit ];
            after = [ databaseContainerUnit ];
            before = [ containerUnit ];
            requiredBy = [ containerUnit ];
            path = [ pkgs.docker ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              for attempt in $(seq 1 60); do
                if docker exec ${databaseContainerName} \
                  pg_isready --username supersync --dbname supersync >/dev/null 2>&1; then
                  exit 0
                fi

                sleep 2
              done

              docker logs ${databaseContainerName} >&2 || true
              echo "Timed out waiting for the SuperSync database" >&2
              exit 1
            '';
          };

          "${containerName}-backup" = {
            description = "Dump the SuperSync PostgreSQL database";
            requires = [ waitForDatabaseUnit ];
            after = [ waitForDatabaseUnit ];
            path = [ pkgs.docker ];
            serviceConfig = {
              Type = "oneshot";
              UMask = "0077";
            };
            script = ''
              set -euo pipefail

              temporaryDump=${lib.escapeShellArg "${backupDir}/supersync.dump.tmp"}
              finalDump=${lib.escapeShellArg "${backupDir}/supersync.dump"}

              rm -f "$temporaryDump"
              docker exec --user postgres ${databaseContainerName} \
                pg_dump \
                  --username supersync \
                  --dbname supersync \
                  --format custom \
                  --clean \
                  --if-exists \
                  --no-owner \
                  --no-privileges \
                > "$temporaryDump"
              mv "$temporaryDump" "$finalDump"
            '';
          };

          "restic-backups-${name}" = {
            requires = [ databaseBackupUnit ];
            after = [ databaseBackupUnit ];
          };
        };
      };

      galaxy = {
        proxy.rules = [
          {
            name = "todo-sync";
            from.host = sync.host;
            to.http = "http://${listenAddress}:${toString sync.port}";
          }
        ];

        backup.paths = [
          stateDir
          backupDir
        ];
      };
    })
  ];
}
