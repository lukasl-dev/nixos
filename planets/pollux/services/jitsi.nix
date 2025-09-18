{ config, lib, pkgs-unstable, ... }:

let
  domain = config.universe.domain;
  host = "meet.${domain}";
  upstreamPort = 8200;
in
{
  services.jitsi-meet = {
    enable = true;

    hostName = host;
    nginx.enable = true;
    prosody.enable = true;
    jicofo.enable = true;
    videobridge.enable = true;
  };

  services.nginx.virtualHosts."${host}" = {
    enableACME = false;
    forceSSL = lib.mkForce false;
    listen = lib.mkForce [
      {
        addr = "127.0.0.1";
        port = upstreamPort;
        ssl = false;
      }
    ];
  };

  services.jitsi-videobridge.openFirewall = true;

  services.traefik.dynamicConfigOptions.http = {
    routers.jitsi = {
      rule = "Host(`meet.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "jitsi";
    };
    services.jitsi.loadBalancer = {
      passHostHeader = true;
      servers = [
        {
          url = "http://127.0.0.1:${toString upstreamPort}";
        }
      ];
    };
  };
}
