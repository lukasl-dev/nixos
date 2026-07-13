{ config, lib, ... }:

let
  inherit (config.galaxy) domain notes;

  listenAddress = "127.0.0.1";

  module = {
    services.nginx = {
      enable = true;

      virtualHosts."notes.${domain}" = {
        listen = [
          {
            addr = listenAddress;
            inherit (notes) port;
          }
        ];

        inherit (notes) root;

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

  };
in
{
  options.galaxy = {
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

  config = lib.mkIf notes.enable (
    lib.mkMerge [
      module
      {
        galaxy = {
          proxy.rules = [
            {
              name = "notes";
              priority = 10;
              to.http = "http://${listenAddress}:${toString notes.port}";
            }
          ];
          backup.paths = [ notes.root ];
        };
      }
    ]
  );
}
