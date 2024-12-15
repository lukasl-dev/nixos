{ config, ... }:

let
  httpPort = 80;
  httpsPort = 443;
  dashboardPort = 8080;
in
{
  networking.firewall.allowedTCPPorts = [
    httpPort
    dashboardPort
    httpsPort
  ];

  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":${toString httpPort}";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":${toString httpsPort}";
          asDefault = true;
          http.tls.certResolver = "letsencrypt";
        };
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "acme@lukasl.dev";
        storage = "${config.services.traefik.dataDir}/acme.json";
        tlsChallenge = true;
        httpChallenge.entryPoint = "web";
      };

      api.dashboard = true;
      api.insecure = true;
    };

    dynamicConfigOptions.http = {
      routers.dashboard = {
        entryPoints = [ "websecure" ];
        service = "api@internal";
        rule = "Host(`sirius.nodes.lukasl.dev`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
        tls.certResolver = "letsencrypt";
      };
      services.dashboard = {
        loadBalancer.servers = [ { url = "http://localhost:${toString dashboardPort}"; } ];
      };
    };
  };
}
