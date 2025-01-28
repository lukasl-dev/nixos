{ meta, config, ... }:

# TODO: postgres, configure properly, enable

{
  services.authelia.instances.default = {
    enable = false;
    settings = {
      theme = "auto";
      default_2fa_method = "totp";
      server.address = "localhost:2718";
    };
    secrets = {
      jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
      sessionSecretFile = config.sops.secrets."authelia/session_secret".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia/storage_encryption_key".path;
    };
  };

  sops.secrets = {
    "authelia/jwt_secret" = { };
    "authelia/session_secret" = { };
    "authelia/storage_encryption_key" = { };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.auth = {
      rule = "Host(`auth.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "auth";
    };
    services.auth = {
      loadBalancer.servers = [
        {
          url = "http://${config.services.authelia.instances.default.server.address}";
        }
      ];
    };
  };
}
