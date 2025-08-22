{ config, pkgs-unstable, ... }:

let
  domain = config.universe.domain;

  forgejo = config.services.forgejo;
in
{
  services.forgejo = {
    enable = true;

    package = pkgs-unstable.forgejo;

    settings = {
      server = {
        DOMAIN = "git.${domain}";
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
        SMTP_ADDR = "mail.lukasl.dev";
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

  services.gitea-actions-runner = {
    package = pkgs-unstable.forgejo-runner;
    instances.pollux = {
      enable = true;
      name = "pollux";
      tokenFile = config.sops.templates."planets/pollux/forgejo/runner-token-file".path;
      url = "https://git.lukasl.dev/";
      labels = [
        "nixos-latest:docker://nixos/nix"
        "ubuntu-latest:docker://node:24-bullseye"
      ];
      settings = { };
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
    routers.git = {
      rule = "Host(`git.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "git";
    };
    services.git = {
      loadBalancer.servers = [
        {
          url = "http://localhost:${toString forgejo.settings.server.HTTP_PORT}";
        }
      ];
    };
  };
}
