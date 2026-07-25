{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.hosting) notes;
  inherit (atlas.hosting.notes) host;

  listenAddress = "127.0.0.1";
  port = 5718;
  root = "/var/www/notes";
in
{
  options.planet.hosting.notes.enable = lib.mkEnableOption "static notes website";

  config = lib.mkIf notes.enable {
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

        locations."/" = {
          index = "index.html";
          tryFiles = "$uri $uri.html $uri/ =404";
        };

        extraConfig = ''
          absolute_redirect off;
          port_in_redirect off;
          error_page 404 /404.html;
        '';
      };
    };

    planet = {
      backup.dirs = [ root ];

      hosting.proxy.rules.notes = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
