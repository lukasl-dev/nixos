{ config, lib, ... }:

let
  inherit (config.galaxy) box;

  listenAddress = "127.0.0.1";

  stateDir = "/var/lib/homebox";
in
{
  options.galaxy = {
    box = {
      enable = lib.mkEnableOption "Enable homebox server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 7745;
        readOnly = true;
        description = "Port for the homebox server.";
      };
    };
  };

  config = lib.mkIf box.enable (
    lib.mkMerge [
      {
        services.homebox = {
          enable = true;

          settings = {
            HBOX_WEB_PORT = toString box.port;
            HBOX_WEB_HOST = listenAddress;
            HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
            HBOX_OPTIONS_GITHUB_RELEASE_CHECK = "false";
          };
        };
      }

      {
        galaxy = {
          proxy.rules = [
            {
              name = "box";
              to.http = "http://${listenAddress}:${toString box.port}";
            }
          ];
          backup.paths = [ stateDir ];
        };
      }
    ]
  );
}
