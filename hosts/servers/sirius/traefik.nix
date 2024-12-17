{ config, ... }:

{
  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
  ];

  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          # http.redirections.entrypoint = {
          #   to = "websecure";
          #   scheme = "https";
          # };
        };

        websecure = {
          address = ":443";
          http.tls.certResolver = "letsencrypt";
        };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "contact@lukasl.dev";
        storage = "${config.services.traefik.dataDir}/acme.json";
        httpChallenge = {
          entryPoint = "web";
        };
      };

      # api.dashboard = true;
      # api.insecure = true;
    };

    dynamicConfigOptions = {
      http = {
        # routers = {
        #   dashboard = {
        #     rule = "Host(`sirius.nodes.lukasl.dev`)";
        #     entryPoints = [ "websecure" ];
        #     service = "api@internal";
        #     tls.certResolver = "letsencrypt";
        #   };
        # };
        # services = { };
      };
    };
  };
}
