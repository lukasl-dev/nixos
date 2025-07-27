{ meta, config, ... }:

let
  httpPort = 80;
  httpsPort = 443;
  submissionPort = 587;
  smtpsPort = 465;
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
                main = "${meta.domain}";
                sans = [ "*.${meta.domain}" ];
              }
            ];
          };
        };

        submission = {
          address = ":${toString submissionPort}";
        };

        smtps = {
          address = ":${toString smtpsPort}";
        };
      };

      log = {
        level = "DEBUG";
      };

      certificatesResolvers = {
        cloudflare = {
          acme = {
            email = "contact@${meta.domain}";
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
          rule = "Host(`proxy.${meta.domain}`)";
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
    "cloudflare/email" = { };
    "cloudflare/account_id" = { };
    "cloudflare/global_api_key" = { };
  };

  sops.templates."traefik/env".content = ''
    CF_API_EMAIL=${config.sops.placeholder."cloudflare/email"}
    CF_API_KEY=${config.sops.placeholder."cloudflare/global_api_key"}
  '';
}
