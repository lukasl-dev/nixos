{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev)
    domain
    addresses
    hole
    ;

  isGuest = hole.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";

  etcDir = "/etc/pihole";
  stateDir = "/var/lib/pihole";

  module = {
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

    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ hole.webPort ];
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

        networking.firewall = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
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
              from.host = hole.host;
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
            hostPort = 53;
            containerPort = 53;
          }
          {
            protocol = "udp";
            hostPort = 53;
            containerPort = 53;
          }
        ];
      })

      (lib.mkIf (!isGuest) module)
    ]
  );
}
