{ config, ... }:

{
  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
  ];

  sops.templates."traefik/env".content = ''
    CF_API_EMAIL=${config.sops.placeholder."cloudflare/email"}
    CF_API_KEY=${config.sops.placeholder."cloudflare/global_api_key"}
  '';

  services.traefik = {
    enable = true;

    environmentFiles = [ (config.sops.templates."traefik/env".path) ];

    staticConfigOptions = {
      api.dashboard = true;

      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":443";
          http.tls = {
            certResolver = "cloudflare";
            domains = [
              (
                let
                  domain = "lukasl.dev";
                in
                {
                  main = "${domain}";
                  sans = [ "*.${domain}" ];
                }
              )
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
            email = "contact@lukasl.dev";
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
          rule = "Host(`proxy.lukasl.dev`)";
          entryPoints = [ "websecure" ];
          service = "api@internal";
        };
      };
    };
  };
}
