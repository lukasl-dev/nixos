{ config, ... }:

let
  domain = config.universe.domain;

  httpPort = 80;
  httpsPort = 443;
in
{
  services.traefik = {
    enable = true;

    environmentFiles = [ (config.sops.templates."traefik/env".path) ];

    staticConfigOptions = {
      api.dashboard = true;

      entryPoints = {
        web = {
          address = ":${toString httpPort}";
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":${toString httpsPort}";
          http.tls = {
            certResolver = "cloudflare";
            domains = [
              {
                main = "${domain}";
                sans = [ "*.${domain}" ];
              }
            ];
          };
        };
      };

      log = {
        level = "DEBUG";
      };

      certificatesResolvers = {
        cloudflare = {
          acme = {
            email = "contact@${domain}";
            storage = "${config.services.traefik.dataDir}/acme.json";
            dnsChallenge = {
              provider = "cloudflare";
              resolvers = [
                "1.1.1.1:53"
                "1.0.0.1:53"
              ];
            };
            # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
          };
        };
      };
    };

    dynamicConfigOptions = {
      http.routers = {
        dashboard = {
          rule = "Host(`proxy.${domain}`)";
          entryPoints = [ "websecure" ];
          service = "api@internal";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
    587
    465
  ];

  sops.secrets = {
    "universe/cloudflare/email" = { };
    "universe/cloudflare/account_id" = { };
    "universe/cloudflare/global_api_key" = { };
  };

  sops.templates."traefik/env".content = ''
    CF_API_EMAIL=${config.sops.placeholder."universe/cloudflare/email"}
    CF_API_KEY=${config.sops.placeholder."universe/cloudflare/global_api_key"}
  '';
}
