{ config, lib, ... }:

let
  inherit (config.galaxy) domain www;

  listenAddress = "127.0.0.1";
in
{
  options.galaxy = {
    www = {
      enable = lib.mkEnableOption "Enable portfolio website";

      port = lib.mkOption {
        type = lib.types.port;
        default = 81;
        readOnly = true;
        description = "Port for the portfolio website";
      };

      root = lib.mkOption {
        type = lib.types.str;
        default = "/var/www/www";
        readOnly = true;
        description = "Location of the built portfolio to be served.";
      };
    };
  };

  config = lib.mkIf www.enable (
    lib.mkMerge [
      {
        services.nginx = {
          enable = true;

          virtualHosts.${domain} = {
            listen = [
              {
                addr = listenAddress;
                inherit (www) port;
              }
            ];
            inherit (www) root;
          };
        };
      }

      {
        galaxy = {
          proxy.rules = [
            {
              name = "www";
              from.host = domain;
              priority = 10;
              to.http = "http://${listenAddress}:${toString www.port}";
            }
          ];
          backup.paths = [ www.root ];
        };
      }
    ]
  );
}
