{ meta, config, ... }:

{
  services.vaultwarden = {
    enable = true;

    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      DOMAIN = "https://vault.${meta.domain}";
      SIGNUPS_ALLOWED = false;
    };
  };

  sops.secrets = {
    "vaultwarden/key" = {
      owner = "vaultwarden";
      path = "/var/lib/bitwarden_rs/rsa_key.pem";
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
