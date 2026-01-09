{
  config,
  pkgs-unstable,
  lib,
  ...
}:

let
  meta = import ./meta.nix;

  sub = "forge";

  hostname = "forge.${meta.domain}";
  port = 7297;
in
{
  pollux.containers.${meta.container} = [
    {
      services.forgejo = {
        enable = true;

        package = pkgs-unstable.forgejo;

        lfs.enable = true;

        settings = {
          DEFAULT = {
            APP_NAME = "Lukas' Forge";
          };

          server = {
            DOMAIN = hostname;
            HTTP_PORT = port;
            ROOT_URL = "https://${hostname}";
          };

          service = {
            DISABLE_REGISTRATION = true;
          };

          metrics = {
            ENABLED = true;
          };

          mailer = {
            ENABLED = true;
            SMTP_ADDR = "mail.${meta.domain}";
            FROM = "bot@${meta.domain}";
            USER = "bot@${meta.domain}";
          };
        };

        secrets = {
          mailer =
            let
              inherit (config.sops) secrets;
            in
            {
              PASSWD = secrets."planets/pollux/maddy/bot".path;
            };
        };
      };

      networking.firewall.allowedTCPPorts = [ port ];

      sops = {
        secrets = {
          "planets/pollux/forgejo/runner" = { };
          "planets/pollux/maddy/bot" = lib.mkDefault { };
        };
        templates."planets/pollux/forgejo/runner-token-file".content = ''
          TOKEN=${config.sops.placeholder."planets/pollux/forgejo/runner"}
        '';
      };
    }
  ];

  services.traefik.dynamicConfigOptions.http =
    let
      name = meta.router sub;
    in
    {
      routers.${name} = {
        rule = "Host(`${sub}.${meta.domain}`)";
        entryPoints = [ "websecure" ];
        service = name;
      };
      services.${name} = {
        loadBalancer.servers = [
          {
            url = "http://${meta.address.local}:${toString port}";
          }
        ];
      };
    };
}
