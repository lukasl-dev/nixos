{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) addresses term;
in
{
  options.galaxy.lukasl-dev = {
    term = {
      enable = lib.mkEnableOption "Enable uptermd";

      port = lib.mkOption {
        type = lib.types.port;
        default = 2222;
        readOnly = true;
        description = "Port for the uptermd server.";
      };
    };
  };

  config = lib.mkIf term.enable {
    # services.traefik = {
    #   staticConfigOptions.entryPoints.uptermd = {
    #     address = ":${toString term.port}";
    #   };
    #
    #   dynamicConfigOptions.tcp = {
    #     services.term = {
    #       loadBalancer = {
    #         servers = [
    #           {
    #             address = "${addresses.local}:${toString term.port}";
    #           }
    #         ];
    #         proxyProtocol.version = 2;
    #       };
    #     };
    #
    #     routers.term = {
    #       rule = "HostSNI(`*`)";
    #       entryPoints = [ "uptermd" ];
    #       service = "term";
    #     };
    #   };
    # };
    #
    # networking.firewall.allowedTCPPorts = [ term.port ];
    #
    # galaxy.lukasl-dev = {
    #   modules = [
    #     {
    #       services.uptermd = {
    #         enable = true;
    #         inherit (term) port;
    #         listenAddress = addresses.local;
    #         openFirewall = true;
    #         extraFlags = [
    #           "--ssh-addr=${addresses.local}:${toString term.port}"
    #           "--ssh-proxy-protocol"
    #         ];
    #       };
    #
    #       networking.firewall.allowedTCPPorts = [ term.port ];
    #     }
    #   ];
    # };
  };
}
