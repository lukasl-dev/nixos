{
  pkgs, config, ... }:

let
  domain = config.universe.domain;
in
{
  services.mealie = {
    enable = true;
    package = pkgs.unstable.mealie;

    port = 1989;
    credentialsFile = config.sops.templates."planets/pollux/mealie/credentials".path;

    settings = {
      ALLOW_SIGNUP = "false";
      TZ = "Europe/Vienna";
      BASE_URL = "https://kitchen.${domain}";

      SMTP_HOST = "mail.${domain}";
      SMTP_PORT = "587";
      SMTP_FROM_NAME = "Mealie";
      SMTP_AUTH_STRATEGY = "TLS";
      SMTP_FROM_EMAIL = "bot@${domain}";
      SMTP_USER = "bot@${domain}";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/private/mealie 0750 mealie mealie - -"
    "Z /var/lib/private/mealie 0750 mealie mealie - -"
  ];

  sops.templates."planets/pollux/mealie/credentials" = {
    content = ''
      SMTP_PASSWORD=${config.sops.placeholder."planets/pollux/maddy/bot"}
    '';
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.mealy = {
      rule = "Host(`kitchen.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "mealy";
    };
    services.mealy = {
      loadBalancer.servers = [
        {
          url = "http://${config.services.mealie.listenAddress}:${toString config.services.mealie.port}";
        }
      ];
    };
  };
}
