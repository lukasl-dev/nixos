{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.hosting) www;
  inherit (atlas.hosting.www) host;

  listenAddress = "127.0.0.1";
  port = 81;
  root = "/var/www/www";
in
{
  options.planet.hosting.www.enable = lib.mkEnableOption "portfolio website";

  config = lib.mkIf www.enable {
    services.nginx = {
      enable = true;

      virtualHosts.${host} = {
        listen = [
          {
            addr = listenAddress;
            inherit port;
          }
        ];
        inherit root;
      };
    };

    planet = {
      backup.dirs = [ root ];

      hosting.proxy.rules.www = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
