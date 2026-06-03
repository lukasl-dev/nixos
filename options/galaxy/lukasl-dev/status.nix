{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) domain addresses status;

  isGuest = status.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/private/uptime-kuma";
in
{
  options.galaxy.lukasl-dev = {
    status = {
      enable = lib.mkEnableOption "Enable Uptime Kuma";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run Uptime Kuma in the lukasl-dev container or on the host.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3141;
        readOnly = true;
        description = "Port for Uptime Kuma.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "status.${domain}";
        readOnly = true;
        description = "Public hostname for Uptime Kuma.";
      };
    };
  };

  config = lib.mkIf status.enable {
    galaxy.lukasl-dev = {
      backup.paths = [
        (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
      ];

      proxy.rules = [
        {
          type = "https";
          name = "status";
          from.host = status.host;
          to.http = "http://${listenAddress}:${toString status.port}";
        }
      ];

      modules = [
        {
          inherit (status) mode;

          module = {
            services.uptime-kuma = {
              enable = true;
              settings = {
                HOST = listenAddress;
                PORT = toString status.port;
              };
            };

            networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ status.port ];
          };
        }
      ];
    };
  };
}
