{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy) cal;

  listenAddress = "127.0.0.1";

  stateDir = "/var/lib/radicale";
in
{
  options.galaxy = {
    cal = {
      enable = lib.mkEnableOption "Enable radicale server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 5232;
        readOnly = true;
        description = "Port for radicale server.";
      };
    };
  };

  config = lib.mkMerge (
    let
      username = "lukas";

      lukasPassword = "galaxy/cal/accounts/lukas";
      htpasswd = "galaxy/cal/htpasswd";
      marioPassword = "galaxy/cal/accounts/mario";

      module = {
        services.radicale = {
          enable = true;

          settings = {
            server = {
              hosts = [ "${listenAddress}:${toString cal.port}" ];
            };

            auth = {
              type = "htpasswd";
              htpasswd_filename = age.secrets.${htpasswd}.path;
              htpasswd_encryption = "bcrypt";
            };

          };

          rights = {
            root = {
              user = ".+";
              collection = "";
              permissions = "R";
            };
            principal = {
              user = ".+";
              collection = "{user}";
              permissions = "RW";
            };
            calendars = {
              user = ".+";
              collection = "{user}/[^/]+";
              permissions = "rw";
            };
          };
        };

      };
    in
    [
      {
        age.secrets = {
          ${lukasPassword} = {
            rekeyFile = ../../secrets/galaxy/cal/accounts/lukas.age;
            generator.script = "alnum";
            intermediary = true;
          };

          ${marioPassword} = {
            rekeyFile = ../../secrets/galaxy/cal/accounts/mario.age;
            generator.script = "alnum";
            intermediary = true;
          };

          ${htpasswd} = {
            rekeyFile = ../../secrets/galaxy/cal/htpasswd.age;
            mode = "0444";
            generator = {
              dependencies = {
                lukasPassword = config.age.secrets.${lukasPassword};
                marioPassword = config.age.secrets.${marioPassword};
              };
              script =
                {
                  pkgs,
                  decrypt,
                  deps,
                  ...
                }:
                let
                  htpasswd = lib.getExe' pkgs.apacheHttpd "htpasswd";
                in
                ''
                  ${decrypt} "${deps.lukasPassword.file}" \
                    | ${htpasswd} -niBC 10 ${username}
                  ${decrypt} "${deps.marioPassword.file}" \
                    | ${htpasswd} -niBC 10 mario
                '';
            };
          };
        };
      }

      (lib.mkIf cal.enable (
        lib.mkMerge [
          module
          {
            galaxy = {
              proxy.rules = [
                {
                  name = "cal";
                  to.http = "http://${listenAddress}:${toString cal.port}";
                }
              ];
              backup.paths = [ stateDir ];
            };
          }
        ]
      ))
    ]
  );
}
