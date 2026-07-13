{ config, lib, ... }:

let
  inherit (config.galaxy) domain household;

  listenAddress = "127.0.0.1";
  stateDir = "/var/lib/grocy";

  module = {
    services = {
      grocy = {
        enable = true;
        hostName = household.host;
        nginx.enableSSL = false;
      };

      nginx.virtualHosts.${household.host}.listen = [
        {
          addr = listenAddress;
          inherit (household) port;
        }
      ];
    };

  };
in
{
  options.galaxy = {
    household = {
      enable = lib.mkEnableOption "Enable Grocy";

      port = lib.mkOption {
        type = lib.types.port;
        default = 9283;
        readOnly = true;
        description = "Port for the Grocy web interface.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "household.${domain}";
        readOnly = true;
        description = "Public hostname for Grocy.";
      };
    };
  };

  config = lib.mkIf household.enable (
    lib.mkMerge [
      module
      {
        galaxy = {
          proxy.rules = [
            {
              name = "household";
              from.host = household.host;
              to.http = "http://${listenAddress}:${toString household.port}";
            }
          ];
          backup.paths = [ stateDir ];
        };
      }
    ]
  );
}
