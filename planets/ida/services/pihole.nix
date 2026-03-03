{ config, ... }:

let
  inherit (config.universe) domain;
  host = "hole.${domain}";
  webPort = 2718;
in
{
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  services.pihole-ftl = {
    enable = true;

    settings = {
      dns = {
        listeningMode = "ALL";
        upstreams = [
          "1.1.1.1"
          "1.0.0.1"
          "8.8.8.8"
          "8.8.4.4"
        ];
      };
    };

    lists = [
      {
        url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
        type = "block";
        enabled = true;
        description = "hagezi blocklist";
      }
    ];
  };

  services.pihole-web = {
    enable = true;
    hostName = host;
    ports = [ webPort ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.pihole = {
      rule = "Host(`${host}`)";
      entryPoints = [ "websecure" ];
      service = "pihole";
      tls = { };
    };

    services.pihole.loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${toString webPort}";
      }
    ];
  };
}
