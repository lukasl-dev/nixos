{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) domain addresses notes;

  isGuest = notes.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
in
{
  options.galaxy.lukasl-dev = {
    notes = {
      enable = lib.mkEnableOption "Enable notes website";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run the notes website in the lukasl-dev container or on the host.";
      };

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
          priority = 10;
          to.http = "http://${listenAddress}:${toString notes.port}";
        }
      ];

      backup.paths = [ notes.root ];

      bindMounts = lib.mkIf isGuest [ notes.root ];

      modules = [
        {
          inherit (notes) mode;

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

            networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ notes.port ];
          };
        }
      ];
    };
  };
}
