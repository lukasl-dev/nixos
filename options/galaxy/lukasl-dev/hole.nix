{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) domain addresses hole;
in
{
  options.galaxy.lukasl-dev = {
    hole = {
      enable = lib.mkEnableOption "Enable Pi-hole";

      webPort = lib.mkOption {
        type = lib.types.port;
        default = 2718;
        readOnly = true;
        description = "Port for the Pi-hole web interface.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "hole.${domain}";
        readOnly = true;
        description = "Public hostname for the Pi-hole web interface.";
      };
    };
  };

  config = lib.mkIf hole.enable {
    services.tailscale.extraUpFlags = lib.mkForce [ "--ssh" ];

    containers.lukasl-dev.forwardPorts = [
      {
        protocol = "tcp";
        hostPort = 53;
        containerPort = 53;
      }
      {
        protocol = "udp";
        hostPort = 53;
        containerPort = 53;
      }
    ];

    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    galaxy.lukasl-dev = {
      backup.paths = [
        "/var/lib/nixos-containers/lukasl-dev/etc/pihole"
        "/var/lib/nixos-containers/lukasl-dev/var/lib/pihole"
      ];

      proxy.rules = [
        {
          type = "https";
          name = "hole";
          from.host = hole.host;
          to.http = "http://${addresses.local}:${toString hole.webPort}";
        }
      ];

      modules = [
        {
          services = {
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
              hostName = hole.host;
              ports = [ hole.webPort ];
            };
          };

          networking.firewall.allowedTCPPorts = [ hole.webPort ];
        }
      ];
    };
  };
}
