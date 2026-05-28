{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) addresses domain household;
in
{
  options.galaxy.lukasl-dev = {
    household = {
      enable = lib.mkEnableOption "Enable Grocy";

      host = lib.mkOption {
        type = lib.types.str;
        default = "household.${domain}";
        readOnly = true;
        description = "Public hostname for Grocy.";
      };
    };
  };

  config = lib.mkIf household.enable {
    galaxy.lukasl-dev = {
      proxy.rules = [
        {
          type = "https";
          name = "household";
          from.host = household.host;
          to.http = "http://${addresses.local}";
        }
      ];

      backup.paths = [
        "/var/lib/nixos-containers/lukasl-dev/var/lib/grocy"
      ];

      modules = [
        {
          services.grocy = {
            enable = true;
            hostName = household.host;
            nginx.enableSSL = false;
          };

          networking.firewall.allowedTCPPorts = [ 80 ];
        }
      ];
    };
  };
}
