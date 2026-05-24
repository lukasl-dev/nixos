{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) domain addresses waka;
in
{
  options.galaxy.lukasl-dev = {
    waka = {
      enable = lib.mkEnableOption "Enable wakapi server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        readOnly = true;
        description = "Port for the wakapi server.";
      };
    };
  };

  config = lib.mkMerge (
    let
      salt = "galaxy/lukasl-dev/waka/salt";
    in
    [
      {
        age.secrets.${salt} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/waka/salt.age;
          mode = "0444";
        };
      }

      (lib.mkIf waka.enable {
        galaxy.lukasl-dev = {
          proxy.rules = [
            {
              type = "https";
              name = "waka";
              to.http = "http://${addresses.local}:${toString waka.port}";
            }
          ];

          bindMounts = [ age.secrets.${salt}.path ];

          modules = [
            {
              services.wakapi = {
                enable = true;

                passwordSaltFile = age.secrets.${salt}.path;

                settings = {
                  server = {
                    public_url = "https://waka.${domain}";
                    listen_ipv4 = addresses.local;
                    inherit (waka) port;
                  };

                  security = {
                    insecure_cookies = false;
                    allow_signup = false;
                  };
                };
              };

              networking.firewall.allowedTCPPorts = [ waka.port ];
            }
          ];
        };
      })
    ]
  );
}
