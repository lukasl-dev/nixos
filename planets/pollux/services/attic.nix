{ config, ... }:

let
  domain = config.universe.domain;

  atticd = config.services.atticd;
  port = 1571;
in
{
  services.atticd = {
    enable = true;

    environmentFile = config.sops.templates."planets/pollux/attic/env".path;

    settings = {
      listen = "[::]:${toString port}";

      jwt = { };

      chunking = {
        nar-size-threshold = 64 * 1024; # 64 KiB
        min-size = 16 * 1024;
        avg-size = 64 * 1024;
        max-size = 256 * 1024;
      };
    };
  };

  users = {
    users.${atticd.user} = {
      isSystemUser = true;
      group = atticd.user;
    };

    groups.${atticd.user} = { };
  };

  sops = {
    secrets."planets/pollux/attic/server_token" = { };
    templates."planets/pollux/attic/env" = {
      owner = atticd.user;
      content = ''
        ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="${
          config.sops.placeholder."planets/pollux/attic/server_token"
        }"
      '';
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.attic = {
      rule = "Host(`nix.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "attic";
    };
    services.attic = {
      loadBalancer.servers = [
        {
          url = "http://localhost:${toString port}";
        }
      ];
    };
  };
}
