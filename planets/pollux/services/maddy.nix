{ config, options, ... }:

let
  domain = config.universe.domain;

  acmeDir = config.security.acme.certs.${domain}.directory;
in
{
  services.maddy = {
    enable = true;

    openFirewall = true;

    primaryDomain = "mail.${domain}";
    hostname = "mail.${domain}";

    ensureAccounts = [ "me@${domain}" ];
    ensureCredentials = {
      "me@${domain}".passwordFile = config.sops.secrets."planets/pollux/maddy/me".path;
    };

    tls = {
      loader = "file";
      certificates = [
        {
          keyPath = "${acmeDir}/key.pem";
          certPath = "${acmeDir}/cert.pem";
        }
      ];
    };

    config =
      builtins.replaceStrings
        [
          "imap tcp://0.0.0.0:143"
          "submission tcp://0.0.0.0:587"
        ]
        [
          "imap tls://0.0.0.0:993 tcp://0.0.0.0:143"
          "submission tls://0.0.0.0:465 tcp://0.0.0.0:587"
        ]
        options.services.maddy.config.default;
  };

  users = {
    users.maddy = {
      isSystemUser = true;
      group = "maddy";
      extraGroups = [ "acme" ];
    };

    groups.maddy = { };
  };

  networking.firewall.allowedTCPPorts = [
    993
    465
  ];

  sops.secrets."planets/pollux/maddy/me" = {
    owner = "maddy";
  };

  services.go-autoconfig = {
    enable = true;
    settings = {
      service_addr = ":1323";
      domain = "autoconfig.${domain}";
      imap = {
        server = config.services.maddy.primaryDomain;
        port = 993;
      };
      smtp = {
        server = config.services.maddy.primaryDomain;
        port = 587;
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.maddy-autoconfig = {
      rule = "Host(`${config.services.go-autoconfig.settings.domain}`)";
      entryPoints = [ "websecure" ];
      service = "maddy-autoconfig";
    };
    services.maddy-autoconfig = {
      loadBalancer.servers = [
        {
          url = "http://localhost${config.services.go-autoconfig.settings.service_addr}";
        }
      ];
    };
  };
}
