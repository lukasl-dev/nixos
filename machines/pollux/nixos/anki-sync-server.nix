{ meta, config, ... }:

{
  services.anki-sync-server = {
    enable = true;
    users = [
      {
        username = "lukas";
        passwordFile = config.sops.secrets."anki/password".path;
      }
    ];
  };

  sops.secrets = {
    "anki/password" = { };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.anki = {
      rule = "Host(`anki.${meta.domain}`)";
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
