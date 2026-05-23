{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) addresses box;
in
{
  options.galaxy.lukasl-dev = {
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

  config = lib.mkIf box.enable {
    galaxy.lukasl-dev = {
      proxy.rules = [
        {
          type = "https";
          name = "box";
          http.to = "http://${addresses.local}:${toString box.port}";
        }
      ];

      modules = [
        {
          services.homebox = {
            enable = true;

            settings = {
              HBOX_WEB_PORT = toString box.port;
              HBOX_WEB_HOST = addresses.local;
              HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
              HBOX_OPTIONS_GITHUB_RELEASE_CHECK = "false";
            };
          };

          networking.firewall.allowedTCPPorts = [ box.port ];
        }
      ];
    };
  };
}
