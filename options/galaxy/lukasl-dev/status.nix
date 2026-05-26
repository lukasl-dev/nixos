{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) domain addresses status;
in
{
  options.galaxy.lukasl-dev = {
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

  config = lib.mkIf status.enable {
    galaxy.lukasl-dev = {
      backup.paths = [
        "/var/lib/nixos-containers/lukasl-dev/var/lib/private/uptime-kuma"
      ];

      proxy.rules = [
        {
          type = "https";
          name = "status";
          from.host = status.host;
          to.http = "http://${addresses.local}:${toString status.port}";
        }
      ];

      modules = [
        {
          services.uptime-kuma = {
            enable = true;
            settings = {
              HOST = addresses.local;
              PORT = toString status.port;
            };
          };

          networking.firewall.allowedTCPPorts = [ status.port ];
        }
      ];
    };
  };
}
