{ config, lib, ... }:

let
  inherit (config.galaxy) domain hole;

  listenAddress = "127.0.0.1";
  dnsPort = 53;

  etcDir = "/etc/pihole";
  stateDir = "/var/lib/pihole";

  module = {
    services = {
      pihole-ftl = {
        enable = true;

        privacyLevel = 1;

        openFirewallDNS = false;

        settings = {
          dns = {
            # NetBird serves its private peer zone on another loopback
            # address on port 53. Bind Pi-hole to its actual LAN interface so
            # both resolvers can coexist.
            interface = "wlan0";
            listeningMode = "BIND";
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
  };
in
{
  options.galaxy = {
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

  config = lib.mkIf hole.enable (
    lib.mkMerge [
      module
      {
        services = {
          resolved.settings.Resolve.DNSStubListener = false;
          tailscale.extraUpFlags = lib.mkForce [ "--ssh" ];
        };

        # Make Pi-hole DNS reachable from the local network. The web interface
        # remains behind the tailscale-only reverse proxy below.
        networking.firewall = {
          allowedTCPPorts = [ dnsPort ];
          allowedUDPPorts = [ dnsPort ];
        };

        galaxy = {
          backup.paths = [
            etcDir
            stateDir
          ];
          proxy.rules = [
            {
              name = "hole";
              from = {
                host = hole.host;
                tailscaleOnly = true;
              };
              to.http = "http://${listenAddress}:${toString hole.webPort}";
            }
          ];
        };
      }
    ]
  );
}
