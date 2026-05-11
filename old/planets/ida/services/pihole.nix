{ config, lib, ... }:

let
  inherit (config.universe) domain;
  host = "hole.${domain}";
  webPort = 2718;
in
{
  services.tailscale.extraUpFlags = lib.mkForce [ "--ssh" ];

  services = {
    resolved.extraConfig = ''
      DNSStubListener=no
    '';

    pihole-ftl = {
      enable = true;

      openFirewallDNS = true;

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

    pihole-web = {
      enable = true;
      hostName = host;
      ports = [ webPort ];
    };

    traefik.dynamicConfigOptions.http = {
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
  };
}
