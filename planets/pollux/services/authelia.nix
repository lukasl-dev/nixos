{ config, ... }:

let
  inherit (config.universe) domain;

  port = 9091;
  dataDir = "/var/lib/authelia-pollux";
  instance = config.services.authelia.instances.pollux;
in
{
  services.authelia.instances.pollux = {
    enable = true;

    secrets = {
      jwtSecretFile = config.sops.secrets."planets/pollux/authelia/jwt_secret".path;
      storageEncryptionKeyFile = config.sops.secrets."planets/pollux/authelia/storage_key".path;
      sessionSecretFile = config.sops.secrets."planets/pollux/authelia/session_secret".path;
    };

    settings = {
      server.address = "tcp://127.0.0.1:${toString port}/";

      authentication_backend.file.path =
        config.sops.secrets."planets/pollux/authelia/users".path;

      storage.local.path = "${dataDir}/db.sqlite3";

      session.cookies = [
        {
          domain = domain;
          authelia_url = "https://auth.${domain}";
        }
      ];

      notifier.filesystem.filename = "${dataDir}/notification.txt";

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = "auth.${domain}";
            policy = "bypass";
          }
        ];
      };
    };
  };

  sops.secrets = {
    "planets/pollux/authelia/jwt_secret" = { owner = instance.user; };
    "planets/pollux/authelia/storage_key" = { owner = instance.user; };
    "planets/pollux/authelia/session_secret" = { owner = instance.user; };
    "planets/pollux/authelia/users" = { owner = instance.user; };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.authelia = {
      rule = "Host(`auth.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "authelia";
    };

    services.authelia = {
      loadBalancer.servers = [
        { url = "http://127.0.0.1:${toString port}"; }
      ];
    };
  };
}
