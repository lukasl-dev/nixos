{ config, pkgs-unstable, ... }:

let
  domain = config.universe.domain;

  forgejo = config.services.forgejo;
in
{
  services.forgejo = {
    enable = true;

    package = pkgs-unstable.forgejo;

    lfs.enable = true;

    settings = {
      DEFAULT = {
        APP_NAME = "Lukas' Forge";
      };

      server = {
        DOMAIN = "forge.${domain}";
        HTTP_PORT = 7297;
        ROOT_URL = "https://${forgejo.settings.server.DOMAIN}";
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
        PASSWD = config.sops.secrets."planets/pollux/maddy/bot".path;
      };
    };
  };

  sops = {
    secrets = {
      "planets/pollux/forgejo/runner" = { };
    };
    templates."planets/pollux/forgejo/runner-token-file".content = ''
      TOKEN=${config.sops.placeholder."planets/pollux/forgejo/runner"}
    '';
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.forge = {
      rule = "Host(`forge.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "forge";
    };
    services.forge = {
      loadBalancer.servers = [
        {
          url = "http://localhost:${toString forgejo.settings.server.HTTP_PORT}";
        }
      ];
    };
  };
}
