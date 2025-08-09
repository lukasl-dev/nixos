{ config, ... }:

let
  domain = config.universe.domain;

  vaultwarden = config.services.vaultwarden;
in
{
  services.vaultwarden = {
    enable = true;

    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      DOMAIN = "https://vault.${domain}";
      SIGNUPS_ALLOWED = false;
    };
  };

  sops.secrets = {
    "planets/pollux/vaultwarden/key" = {
      owner = "vaultwarden";
      path = "/var/lib/bitwarden_rs/rsa_key.pem";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule = "Host(`vault.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "vaultwarden";
    };
    services.vaultwarden = {
      loadBalancer.servers = [
        {
          url = "http://${vaultwarden.config.ROCKET_ADDRESS}:${toString vaultwarden.config.ROCKET_PORT}";
        }
      ];
    };
  };
}
