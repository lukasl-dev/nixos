{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) domain addresses notes;
in
{
  options.galaxy.lukasl-dev = {
    notes = {
      enable = lib.mkEnableOption "Enable notes website";

      port = lib.mkOption {
        type = lib.types.port;
        default = 5718;
        readOnly = true;
        description = "Port for the notes website";
      };

      root = lib.mkOption {
        type = lib.types.str;
        default = "/var/www/notes";
        readOnly = true;
        description = "Location of the built notes to be served.";
      };
    };
  };

  config = lib.mkIf notes.enable {
    galaxy.lukasl-dev = {
      proxy.rules = [
        {
          type = "https";
          name = "notes";
          to.http = "http://${addresses.local}:${toString notes.port}";
        }
      ];

      modules = [
        {
          services.nginx.virtualHosts."notes.${domain}" = {
            listen = [
              {
                addr = addresses.local;
                inherit (notes) port;
              }
            ];
            inherit (notes) root;
            locations."/" = {
              index = "index.html";
              tryFiles = "$uri $uri.html $uri/ =404";
            };
            extraConfig = ''
              error_page 404 /404.html;
            '';
          };
        }
      ];
    };
  };
}
