{ config, lib, ... }:

let
  inherit (config.planet.networking) dns;
in
{
  options.planet.networking.dns = {
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
  };

  config = {
    networking.networkmanager = {
      enable = lib.mkDefault true;
      dns = "systemd-resolved";
    };

    services.resolved = {
      enable = true;
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
    };

    services.avahi = lib.mkIf dns.discoverable {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  };
}
