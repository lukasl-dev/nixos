{ config, lib, ... }:

let
  inherit (config.galaxy) domain status;

  listenAddress = "127.0.0.1";

  stateDir = "/var/lib/private/uptime-kuma";
in
{
  options.galaxy = {
    status = {
      enable = lib.mkEnableOption "Enable Uptime Kuma";

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

  config = lib.mkIf status.enable (
    lib.mkMerge [
      {
        services.uptime-kuma = {
          enable = true;
          settings = {
            HOST = listenAddress;
            PORT = toString status.port;
          };
        };
      }

      {
        galaxy = {
          backup.paths = [ stateDir ];
          proxy.rules = [
            {
              name = "status";
              from.host = status.host;
              to.http = "http://${listenAddress}:${toString status.port}";
            }
          ];
        };
      }
    ]
  );
}
