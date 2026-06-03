{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) name;

  inherit (config.galaxy) lukasl-dev;
  inherit (config.galaxy.lukasl-dev) addresses backup;

  isGuest = backup.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";

  password = "galaxy/lukasl-dev/backup/password";
  token = "galaxy/lukasl-dev/backup/token";
  htpasswd = "galaxy/lukasl-dev/backup/htpasswd";
  env = "galaxy/lukasl-dev/backup/env";
in
{
  options.galaxy.lukasl-dev = {
    backup = {
      enable = lib.mkEnableOption "Enable backup server";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run the restic REST server in the lukasl-dev container or on the host.";
      };

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
        default = "backup.${lukasl-dev.domain}";
        readOnly = true;
        description = "Public hostname for the restic REST server.";
      };

      paths = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "Host paths to include in the lukasl-dev restic backup.";
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets = {
        ${password} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/backup/password.age;
        };

        ${token} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/backup/token.age;
          generator.script = "alnum";
          intermediary = true;
        };

        ${htpasswd} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/backup/htpasswd.age;
          mode = "0444";
          generator = {
            dependencies = {
              token = age.secrets.${token};
            };
            script =
              { decrypt, deps, ... }:
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
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/backup/env.age;
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
          assertion = lukasl-dev.enable;
          message = "galaxy.lukasl-dev.enable must be true when galaxy.lukasl-dev.backup.enable is true.";
        }
        {
          assertion = backup.dataDir != null;
          message = "galaxy.lukasl-dev.backup.dataDir must be configured when backup.enable is true.";
        }
      ];
    })

    (lib.mkIf (lukasl-dev.enable && backup.enable && backup.dataDir != null) {
      containers.lukasl-dev.bindMounts.${backup.dataDir} = lib.mkIf isGuest {
        hostPath = backup.dataDir;
        isReadOnly = false;
      };

      galaxy.lukasl-dev = {
        bindMounts = lib.mkIf isGuest [ age.secrets.${htpasswd}.path ];

        proxy.rules = [
          {
            type = "https";
            name = "backup";
            from.host = backup.host;
            to.http = "http://${listenAddress}:${toString backup.port}";
          }
        ];

        modules = [
          {
            inherit (backup) mode;

            module = {
              services.restic.server = {
                enable = true;
                inherit (backup) dataDir;
                listenAddress = "${listenAddress}:${toString backup.port}";
                htpasswd-file = age.secrets.${htpasswd}.path;
              };

              networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ backup.port ];
            };
          }
        ];
      };
    })

    (lib.mkIf (lukasl-dev.enable && backup.paths != [ ]) {
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
