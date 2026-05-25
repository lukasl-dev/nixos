{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev)
    domain
    addresses
    forge
    mail
    ;
in
{
  options.galaxy.lukasl-dev = {
    forge = {
      enable = lib.mkEnableOption "Enable forgejo server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 7297;
        readOnly = true;
        description = "Port for the forgejo http server.";
      };

      sshPort = lib.mkOption {
        type = lib.types.port;
        default = 2222;
        readOnly = true;
        description = "External and container port for the forgejo SSH server.";
      };
    };
  };

  config = lib.mkMerge (
    let
      # TODO:
    in
    [
      {
        age.secrets = {
          # TODO:
        };
      }

      (lib.mkIf forge.enable {
        containers.lukasl-dev.forwardPorts = [
          {
            protocol = "tcp";
            hostPort = forge.sshPort;
            containerPort = forge.sshPort;
          }
        ];

        galaxy.lukasl-dev = {
          proxy.rules = [
            {
              type = "https";
              name = "forge";
              to.http = "http://${addresses.local}:${toString forge.port}";
            }
          ];

          bindMounts = [ age.secrets.${mail.accounts.bot}.path ];

          modules = [
            {
              services.forgejo = {
                enable = true;

                package = pkgs.unstable.forgejo;

                lfs.enable = true;

                settings = {
                  DEFAULT = {
                    APP_NAME = "Lukas' Forge";
                  };

                  server =
                    let
                      hostname = "forge.${domain}";
                    in
                    {
                      DOMAIN = hostname;
                      HTTP_ADDR = addresses.local;
                      HTTP_PORT = forge.port;
                      ROOT_URL = "https://${hostname}";
                    SSH_DOMAIN = hostname;
                    SSH_PORT = forge.sshPort;
                    SSH_LISTEN_PORT = forge.sshPort;
                    START_SSH_SERVER = true;
                    };

                  service = {
                    DISABLE_REGISTRATION = true;
                  };

                  metrics = {
                    ENABLED = true;
                  };

                  mailer = {
                    ENABLED = true;
                    SMTP_ADDR = mail.host;
                    FROM = "bot@${domain}";
                    USER = "bot@${domain}";
                  };
                };

                secrets = {
                  mailer = {
                    PASSWD = age.secrets.${mail.accounts.bot}.path;
                  };
                };
              };

              networking.firewall.allowedTCPPorts = [
                forge.port
                forge.sshPort
              ];
            }
          ];
        };
      })
    ]
  );
}
