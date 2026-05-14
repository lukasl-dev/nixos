{ config, lib, ... }:

let
  inherit (config.galaxy) proxy;
in
{
  options.galaxy.proxy = {
    enable = lib.mkEnableOption "Enable reverse proxy";
  };

  config = lib.mkIf proxy.enable (
    let
      httpPort = 80;
      httpsPort = 443;
    in
    {
      # TODO: acme

      services.traefik = {
        enable = true;

        staticConfigOptions = {
          api.dashboard = false;

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
                readTimeout = "0s";
                writeTimeout = "0s";
                idleTimeout = "600s";
              };
            };

            # uptermd = {
            #   address = ":2222";
            # };
          };
        };
      };

      users.users.traefik.extraGroups = [ "acme" ];

      networking.firewall.allowedTCPPorts = [
        httpPort
        httpsPort
        8080
      ];
    }
  );
}
