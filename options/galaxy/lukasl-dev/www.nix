{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) domain addresses www;
in
{
  options.galaxy.lukasl-dev = {
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

  config = lib.mkIf www.enable {
    galaxy.lukasl-dev = {
      proxy.rules = [
        {
          type = "https";
          name = "www";
          from.host = domain;
          priority = 10;
          to.http = "http://${addresses.local}:${toString www.port}";
        }
      ];

      backup.paths = [ www.root ];

      bindMounts = [ www.root ];

      modules = [
        {
          services.nginx = {
            enable = true;

            virtualHosts.${domain} = {
              listen = [
                {
                  addr = addresses.local;
                  inherit (www) port;
                }
              ];
              inherit (www) root;
            };
          };

          networking.firewall.allowedTCPPorts = [ www.port ];
        }
      ];
    };
  };
}
