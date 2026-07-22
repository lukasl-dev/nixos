{ config, lib, ... }:

let
  inherit (config) planet;
in
{
  options.planet.dns = {
    discoverable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Make this machine discoverable (hostname.local).";
    };
  };

  networking.networkmanager.dns = "systemd-resolved";

  services = {
    resolved = {
      enable = true;
      settings.Resolve = {
        FallbackDNS = [
          "1.1.1.1"
          "1.0.0.1"

          "8.8.8.8"
          "8.8.4.4"
        ];
        DNSStubListenerExtra = [ planet.containers.dns ];
      };
    };

    avahi = lib.mkIf planet.dns.discoverable {
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
}
