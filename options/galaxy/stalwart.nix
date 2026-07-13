{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.galaxy) domain stalwart;

  listenAddress = "127.0.0.1";
  stateDir = "/var/lib/stalwart";
  bootstrapStateDir = "/var/lib/stalwart-bootstrap";
  adminPasswordFile = "${bootstrapStateDir}/admin-password";
in
{
  options.galaxy.stalwart = {
    enable = lib.mkEnableOption "Enable Stalwart collaboration server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      readOnly = true;
      description = "Port for the Stalwart HTTP server.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "stalwart.${domain}";
      readOnly = true;
      description = "Public hostname for the Stalwart server.";
    };
  };

  config = lib.mkIf stalwart.enable {
    services.stalwart = {
      enable = true;
      stateVersion = "26.05";

      credentials.admin-password = adminPasswordFile;

      settings = {
        server = {
          hostname = stalwart.host;
          listener.http = {
            bind = [ "${listenAddress}:${toString stalwart.port}" ];
            protocol = "http";
          };
        };

        http = {
          url = "https://${stalwart.host}";
          use-x-forwarded = true;
        };

        authentication.fallback-admin = {
          user = "admin";
          secret = "%{file:/run/credentials/stalwart.service/admin-password}%";
        };
      };
    };

    systemd.services = {
      stalwart = {
        requires = [ "stalwart-admin-password.service" ];
        after = [ "stalwart-admin-password.service" ];
      };

      stalwart-admin-password = {
        description = "Create the Stalwart bootstrap administrator password";
        before = [ "stalwart.service" ];

        script = ''
          set -euo pipefail

          if [[ ! -s ${lib.escapeShellArg adminPasswordFile} ]]; then
            ${lib.getExe' pkgs.openssl "openssl"} rand -hex 32 > ${lib.escapeShellArg adminPasswordFile}
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          StateDirectory = "stalwart-bootstrap";
          StateDirectoryMode = "0700";
          UMask = "0077";
        };
      };
    };

    galaxy = {
      proxy.rules = [
        {
          name = "stalwart";
          from.host = stalwart.host;
          to.http = "http://${listenAddress}:${toString stalwart.port}";
        }
      ];

      backup.paths = [
        stateDir
        bootstrapStateDir
      ];
    };
  };
}
