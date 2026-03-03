{ config, ... }:

let
  inherit (config.universe) domain;
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
          http.tls = { };
          transport.respondingTimeouts = {
            # allow long uploads and slow clients
            readTimeout = "0s"; # no limit
            writeTimeout = "0s"; # no limit
            idleTimeout = "600s"; # keep idle conns longer
          };
        };
      };
    };

    dynamicConfigOptions.http.routers.dashboard = {
      rule = "Host(`proxy.ida.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "api@internal";
      tls = { };
    };

    dynamicConfigOptions.tls.certificates = [
      {
        certFile = "${acmeDir}/fullchain.pem";
        keyFile = "${acmeDir}/key.pem";
      }
    ];
  };

  users.users.traefik.extraGroups = [ "acme" ];

  networking.firewall.allowedTCPPorts = [
    httpPort
    httpsPort
    8080
  ];
}
