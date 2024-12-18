{ meta, config, ... }:

{
  services.vaultwarden = {
    enable = false;

    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      DOMAIN = "https://vault.${meta.domain}";
      SIGNUPS_ALLOWED = false;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule = "Host(`vault.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "vaultwarden";
    };
    services.vaultwarden = {
      loadBalancer.servers = [
        {
          url = "http://${config.services.vaultwarden.config.ROCKET_ADDRESS}:${toString config.services.vaultwarden.config.ROCKET_PORT}";
        }
      ];
    };
  };
}
