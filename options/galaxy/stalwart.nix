{
  config,
  inputs,
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
  # The pinned stable nixpkgs predates Stalwart's collaboration support and
  # still provides services.stalwart-mail 0.11. Use the current module so that
  # services.stalwart can run a CalDAV/CardDAV/WebDAV-capable release.
  disabledModules = [
    "services/mail/stalwart-mail.nix"
  ];

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/mail/stalwart.nix"
  ];

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
      package = pkgs.unstable.stalwart;
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

        # The newer Stalwart module uses the newer scalar ExecStartPre syntax.
        # Keep it compatible with the pinned NixOS systemd module.
        serviceConfig.ExecStartPre = lib.mkForce [
          "${lib.getExe' pkgs.coreutils "mkdir"} -p ${stateDir}/db"
        ];
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
