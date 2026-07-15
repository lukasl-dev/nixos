{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.planet) name;

  inherit (config.galaxy) backup domain;

  listenAddress = "127.0.0.1";

  password = "galaxy/backup/password";
  token = "galaxy/backup/token";
  htpasswd = "galaxy/backup/htpasswd";
  env = "galaxy/backup/env";
in
{
  options.galaxy = {
    backup = {
      enable = lib.mkEnableOption "Enable backup server";

      dataDir = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Directory where the restic REST server stores repositories.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8000;
        readOnly = true;
        description = "Port for the restic REST server.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "backup.${domain}";
        readOnly = true;
        description = "Public hostname for the restic REST server.";
      };

      paths = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "Host paths to include in this machine's restic backup.";
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets = {
        ${password} = {
          rekeyFile = ../../secrets/galaxy/backup/password.age;
        };

        ${token} = {
          rekeyFile = ../../secrets/galaxy/backup/token.age;
          generator.script = "alnum";
          intermediary = true;
        };

        ${htpasswd} = {
          rekeyFile = ../../secrets/galaxy/backup/htpasswd.age;
          mode = "0444";
          generator = {
            dependencies = {
              token = age.secrets.${token};
            };
            script =
              {
                pkgs,
                decrypt,
                deps,
                ...
              }:
              let
                htpasswd = lib.getExe' pkgs.apacheHttpd "htpasswd";
              in
              ''
                token="$(${decrypt} "${deps.token.file}")"
                hash="$(printf '%s\n' "$token" | ${htpasswd} -niBC 10 backup | cut -d: -f2-)"
                printf 'backup:%s\n' "$hash"
              '';
          };
        };

        ${env} = {
          rekeyFile = ../../secrets/galaxy/backup/env.age;
          generator = {
            dependencies = {
              token = age.secrets.${token};
            };
            script =
              { decrypt, deps, ... }:
              ''
                token="$(${decrypt} "${deps.token.file}")"
                printf 'RESTIC_REST_USERNAME=backup\n'
                printf 'RESTIC_REST_PASSWORD=%s\n' "$token"
              '';
          };
        };
      };
    }

    (lib.mkIf backup.enable {
      assertions = [
        {
          assertion = backup.dataDir != null;
          message = "galaxy.backup.dataDir must be configured when backup.enable is true.";
        }
      ];
    })

    (lib.mkIf (backup.enable && backup.dataDir != null) (
      lib.mkMerge [
        {
          services.restic.server = {
            enable = true;
            inherit (backup) dataDir;
            listenAddress = "${listenAddress}:${toString backup.port}";
            htpasswd-file = age.secrets.${htpasswd}.path;
          };
        }

        {
          galaxy.proxy.rules = [
            {
              name = "backup";
              from.host = backup.host;
              to.http = "http://${listenAddress}:${toString backup.port}";
            }
          ];
        }
      ]
    ))

    (lib.mkIf (backup.paths != [ ]) {
      services.restic.backups.${name} = {
        initialize = true;
        repository = "rest:https://${backup.host}/${name}";
        environmentFile = age.secrets.${env}.path;
        passwordFile = age.secrets.${password}.path;
        paths = lib.unique backup.paths;
        pruneOpts = [ "--keep-daily 14" ];
      };
    })
  ];
}
