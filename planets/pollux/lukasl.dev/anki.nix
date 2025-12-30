{ config, ... }:

let
  domain = import ./domain.nix;
in
{
  services = {
    anki-sync-server = {
      enable = true;
      users = [
        {
          username = "lukas";
          passwordFile = config.sops.secrets."planets/pollux/anki/password".path;
        }
      ];
    };

    traefik.dynamicConfigOptions.http = {
      routers.anki = {
        rule = "Host(`anki.${domain}`)";
        entryPoints = [ "websecure" ];
        service = "anki";
      };
      services.anki = {
        loadBalancer.servers =
          let
            inherit (config.services.anki-sync-server) address port;
          in
          [
            {
              url = "http://${address}:${toString port}";
            }
          ];
      };
    };
  };

  sops.secrets = {
    "planets/pollux/anki/password" = { };
  };
}
