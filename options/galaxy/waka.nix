{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy) domain waka;

  listenAddress = "127.0.0.1";
  stateDir = "/var/lib/private/wakapi";

  salt = "galaxy/waka/salt";
  env = "galaxy/waka/env";
in
{
  options.galaxy = {
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

  config = lib.mkMerge [
    {
      age.secrets = {
        ${salt} = {
          rekeyFile = ../../secrets/galaxy/waka/salt.age;
          intermediary = true;
        };

        ${env} = {
          rekeyFile = ../../secrets/galaxy/waka/env.age;
          generator = {
            dependencies.salt = age.secrets.${salt};
            script =
              { decrypt, deps, ... }:
              ''
                salt="$(${decrypt} "${deps.salt.file}")"
                printf 'WAKAPI_PASSWORD_SALT=%s\n' "$salt"
              '';
          };
        };
      };
    }

    (lib.mkIf waka.enable (
      lib.mkMerge [
        {
          services.wakapi = {
            enable = true;
            environmentFiles = [ age.secrets.${env}.path ];

            settings = {
              server = {
                public_url = "https://waka.${domain}";
                listen_ipv4 = listenAddress;
                inherit (waka) port;
              };

              security = {
                insecure_cookies = false;
                allow_signup = false;
              };
            };
          };
        }

        {
          galaxy = {
            proxy.rules = [
              {
                name = "waka";
                to.http = "http://${listenAddress}:${toString waka.port}";
              }
            ];
            backup.paths = [ stateDir ];
          };
        }
      ]
    ))
  ];
}
