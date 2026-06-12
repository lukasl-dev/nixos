{ config, lib, ... }:

let
  inherit (config.planet.networking) dns;

  hasHostPihole =
    (config.galaxy.lukasl-dev.hole.enable or false)
    && (config.galaxy.lukasl-dev.hole.mode or null) == "host";

  fallbackDns = builtins.concatLists [
    (lib.optionals (lib.elem "cloudflare" dns.providers) [
      "1.1.1.1"
      "1.0.0.1"
    ])
    (lib.optionals (lib.elem "google" dns.providers) [
      "8.8.8.8"
      "8.8.4.4"
    ])
  ];
in
{
  options.planet.networking = {
    dns = {
      providers = lib.mkOption {
        type = lib.types.listOf (
          lib.types.enum [
            "cloudflare"
            "google"
          ]
        );
        default = [
          "cloudflare"
          "google"
        ];
        description = "DNS providers used as fallback when VPN is disconnected.";
        example = [
          "cloudflare"
          "google"
        ];
      };

      discoverable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Make this machine discoverable (hostname.local).";
      };

      dockerAddress = lib.mkOption {
        type = lib.types.str;
        default = "172.17.0.1";
        readOnly = true;
        description = "Host-side Docker bridge address used by containers for DNS.";
      };
    };
  };

  config = {
    networking.networkmanager = {
      enable = lib.mkDefault true;
      dns = "systemd-resolved";
    };

    services = {
      resolved = {
        enable = true;
        inherit fallbackDns;

        # Docker containers cannot use systemd-resolved's default 127.0.0.53
        # stub, because that loopback address is inside the container. Expose a
        # second stub on the host-side Docker bridge and point Docker at it.
        extraConfig = lib.mkIf (!hasHostPihole) ''
          DNSStubListenerExtra=${dns.dockerAddress}
        '';
      };

      avahi = lib.mkIf dns.discoverable {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
          userServices = true;
        };
      };
    };

    networking.firewall.interfaces.docker0 = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
