{ config, ... }:

let
  domain = config.universe.domain;

  acmeDir = config.security.acme.certs.${domain}.directory;

  httpPort = 80;
  httpsPort = 443;
in
{
  services.traefik = {
    enable = true;

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
          http = {
            tls = { };
            transport.respondingTimeouts = {
              # Allow long uploads and slow clients
              readTimeout = "0s";   # no limit
              writeTimeout = "0s";  # no limit
              idleTimeout = "600s"; # keep idle conns longer
            };
          };
        };
      };

      log = {
        level = "DEBUG";
      };
    };

    dynamicConfigOptions = {
      tls.certificates = [
        {
          certFile = "${acmeDir}/fullchain.pem";
          keyFile = "${acmeDir}/key.pem";
        }
      ];
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

  users.users.traefik.extraGroups = [ "acme" ];
}
