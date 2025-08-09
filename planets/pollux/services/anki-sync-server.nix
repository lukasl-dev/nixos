{ config, ... }:

let
  domain = config.universe.domain;
in
{
  services.anki-sync-server = {
    enable = true;
    users = [
      {
        username = "lukas";
        passwordFile = config.sops.secrets."planets/pollux/anki/password".path;
      }
    ];
  };

  sops.secrets = {
    "planets/pollux/anki/password" = { };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.anki = {
      rule = "Host(`anki.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "anki";
    };
    services.anki = {
      loadBalancer.servers = [
        {
          url = "http://${config.services.anki-sync-server.address}:${toString config.services.anki-sync-server.port}";
        }
      ];
    };
  };
}
