{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) domain addresses www;

  isGuest = www.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";

  module = {
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

    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ www.port ];
  };
in
{
  options.galaxy.lukasl-dev = {
    www = {
      enable = lib.mkEnableOption "Enable portfolio website";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run the portfolio website in the lukasl-dev container or on the host.";
      };

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
        galaxy.lukasl-dev = {
          proxy.rules = [
            {
              type = "https";
              name = "www";
              from.host = domain;
              priority = 10;
              to.http = "http://${listenAddress}:${toString www.port}";
            }
          ];

          backup.paths = [ www.root ];

          bindMounts = lib.mkIf isGuest [ www.root ];

          modules.www = {
            inherit (www) mode;
            inherit module;
          };
        };
      }

      (lib.mkIf (!isGuest) module)
    ]
  );
}
