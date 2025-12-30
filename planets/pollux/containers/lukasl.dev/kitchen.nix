let
  meta = import ./meta.nix;

  sub = "kitchen";

  port = 1989;
in
{
  pollux.containers.${meta.container} = [
    (
      { config, lib, ... }:
      let
        inherit (config.sops) templates placeholder;
      in
      {
        services.mealie = {
          enable = true;

          inherit port;
          credentialsFile = templates."planets/pollux/mealie/credentials".path;

          settings = {
            ALLOW_SIGNUP = "false";
            TZ = "Europe/Vienna";
            BASE_URL = "https://kitchen.${meta.domain}";

            SMTP_HOST = "mail.${meta.domain}";
            SMTP_PORT = "587";
            SMTP_FROM_NAME = "Mealie";
            SMTP_AUTH_STRATEGY = "TLS";
            SMTP_FROM_EMAIL = "bot@${meta.domain}";
            SMTP_USER = "bot@${meta.domain}";
          };
        };

        networking.firewall.allowedTCPPorts = [ port ];

        systemd.tmpfiles.rules = [
          "d /var/lib/private/mealie 0750 mealie mealie - -"
          "Z /var/lib/private/mealie 0750 mealie mealie - -"
        ];

        sops = {
          secrets."planets/pollux/maddy/bot" = lib.mkDefault { };

          templates."planets/pollux/mealie/credentials" = {
            content = ''
              SMTP_PASSWORD=${placeholder."planets/pollux/maddy/bot"}
            '';
          };
        };
      }
    )
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
