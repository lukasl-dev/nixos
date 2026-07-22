{ config, lib, ... }:

let
  inherit (config) planet;
in
{
  options.planet.virtualisation.containers = {
    dns = lib.mkOption {
      type = lib.types.str;
      default = "172.17.0.1";
      internal = true;
      readOnly = true;
    };
  };

  config = {
    virtualisation = {
      docker = {
        enable = true;
        daemon.settings.dns = [ planet.virtualisation.containers.dns ];

        rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings.dns = [ planet.virtualisation.containers.dns ];
        };
      };
      oci-containers.backend = "docker";
    };

    services.resolved.settings.Resolve.DNSStubListenerExtra = [
      planet.virtualisation.containers.dns
    ];

    networking.firewall = {
      interfaces.docker0 = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };

      # Docker's embedded DNS forwards queries from user-defined networks to
      # the resolver on docker0. Those packets enter the host through the
      # corresponding br-* interface, not docker0 itself.
      extraInputRules = ''
        iifname "br-*" tcp dport 53 accept
        iifname "br-*" udp dport 53 accept
      '';
    };
  };
}
