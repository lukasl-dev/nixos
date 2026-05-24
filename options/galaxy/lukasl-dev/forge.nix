{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) domain addresses forge;
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
    };
  };

  config = lib.mkIf forge.enable (
    let
      mailPassword = "galaxy/lukasl-dev/mail/bot";
    in
    {
      age.secrets = {
        ${mailPassword} = lib.mkDefault {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/mail/bot.age;
        };
      };

      galaxy.lukasl-dev = {
        proxy.rules = [
          {
            type = "https";
            name = "forge";
            to.http = "http://${addresses.local}:${toString forge.port}";
          }
        ];

        modules =
          let
            user = "forge";
            group = "forge";
          in
          [
            {
              services.forgejo = {
                enable = true;

                package = pkgs.unstable.forgejo;

                inherit user;
                inherit group;

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
                      HTTP_PORT = forge.port;
                      ROOT_URL = "https://${hostname}";
                      SSH_PORT = 22;
                    };

                  service = {
                    DISABLE_REGISTRATION = true;
                  };

                  metrics = {
                    ENABLED = true;
                  };

                  mailer = {
                    ENABLED = true;
                    SMTP_ADDR = "mail.${domain}";
                    FROM = "bot@${domain}";
                    USER = "bot@${domain}";
                  };
                };

                secrets = {
                  mailer = {
                    PASSWD = age.secrets.${mailPassword}.path;
                  };
                };
              };

              networking.firewall.allowedTCPPorts = [ forge.port ];

              users.users.${forge} = {
                isSystemUser = true;
                inherit group;
              };
              users.groups.${group} = { };
            }
          ];
      };

    }
  );
}
