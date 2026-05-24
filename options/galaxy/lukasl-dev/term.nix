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
    galaxy.lukasl-dev = {
      # TODO: add TCP support
      # proxy.rules = [
      #   {
      #     type = "https";
      #     name = "term";
      #     to.http = "http://${addresses.local}:${toString term.port}";
      #   }
      # ];
      # services.traefik.dynamicConfigOptions.tcp =
      #   let
      #     name = meta.router sub;
      #   in
      #   {
      #     services.${name} = {
      #       loadBalancer = {
      #         servers = [
      #           {
      #             address = "${meta.address.local}:${toString sshPort}";
      #           }
      #         ];
      #         proxyProtocol.version = 2;
      #       };
      #     };
      #     routers.${name} = {
      #       rule = "HostSNI(`*`)";
      #       entryPoints = [ "uptermd" ];
      #       service = name;
      #     };
      #   };

      modules = [
        {
          services.uptermd = {
            enable = true;
            inherit (term) port;
            listenAddress = addresses.local;
            openFirewall = true;
            extraFlags = [
              "--ssh-addr=${addresses.local}:${toString term.port}"
              "--ssh-proxy-protocol"
            ];
          };

          networking.firewall.allowedTCPPorts = [ term.port ];
        }
      ];
    };
  };
}
