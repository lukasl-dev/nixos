{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.hosting) household;
  inherit (atlas.hosting.household) host;

  listenAddress = "127.0.0.1";
  port = 9283;
  stateDir = "/var/lib/grocy";
in
{
  options.planet.hosting.household.enable = lib.mkEnableOption "Grocy server";

  config = lib.mkIf household.enable {
    services = {
      grocy = {
        enable = true;
        hostName = host;
        nginx.enableSSL = false;
      };

      nginx.virtualHosts.${host}.listen = [
        {
          addr = listenAddress;
          inherit port;
        }
      ];
    };

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules.household = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
