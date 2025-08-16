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
    };
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
