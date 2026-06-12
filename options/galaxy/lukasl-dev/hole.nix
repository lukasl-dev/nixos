{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev)
    domain
    addresses
    hole
    ;

  isGuest = hole.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
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

    networking.firewall = lib.mkIf isGuest {
      # The container firewall needs to allow DNS for forwarded requests from
      # the host. The web UI is still only reachable from the host/reverse proxy.
      allowedTCPPorts = [
        dnsPort
        hole.webPort
      ];
      allowedUDPPorts = [ dnsPort ];
    };
  };
in
{
  options.galaxy.lukasl-dev = {
    hole = {
      enable = lib.mkEnableOption "Enable Pi-hole";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run Pi-hole in the lukasl-dev container or on the host.";
      };

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
      {
        services = {
          resolved.extraConfig = lib.mkIf (!isGuest) ''
            DNSStubListener=no
          '';

          tailscale.extraUpFlags = lib.mkForce [ "--ssh" ];
        };

        # Make Pi-hole DNS reachable from the local network. The web interface
        # remains behind the tailscale-only reverse proxy below.
        networking.firewall = {
          allowedTCPPorts = [ dnsPort ];
          allowedUDPPorts = [ dnsPort ];
        };

        galaxy.lukasl-dev = {
          backup.paths = [
            (if isGuest then "/var/lib/nixos-containers/lukasl-dev${etcDir}" else etcDir)
            (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
          ];

          proxy.rules = [
            {
              type = "https";
              name = "hole";
              from = {
                host = hole.host;
                tailscaleOnly = true;
              };
              to.http = "http://${listenAddress}:${toString hole.webPort}";
            }
          ];

          modules.hole = {
            inherit (hole) mode;
            inherit module;
          };
        };
      }

      (lib.mkIf isGuest {
        containers.lukasl-dev.forwardPorts = [
          {
            protocol = "tcp";
            hostPort = dnsPort;
            containerPort = dnsPort;
          }
          {
            protocol = "udp";
            hostPort = dnsPort;
            containerPort = dnsPort;
          }
        ];
      })

      (lib.mkIf (!isGuest) module)
    ]
  );
}
