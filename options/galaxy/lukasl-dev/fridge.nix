{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) addresses domain fridge;
in
{
  options.galaxy.lukasl-dev = {
    fridge = {
      enable = lib.mkEnableOption "Enable Grocy";

      host = lib.mkOption {
        type = lib.types.str;
        default = "fridge.${domain}";
        readOnly = true;
        description = "Public hostname for Grocy.";
      };
    };
  };

  config = lib.mkIf fridge.enable {
    galaxy.lukasl-dev = {
      proxy.rules = [
        {
          type = "https";
          name = "fridge";
          from.host = fridge.host;
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
            hostName = fridge.host;
            nginx.enableSSL = false;
          };

          networking.firewall.allowedTCPPorts = [ 80 ];
        }
      ];
    };
  };
}
