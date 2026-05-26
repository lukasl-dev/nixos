{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) addresses cal;
in
{
  options.galaxy.lukasl-dev = {
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

      password = "galaxy/lukasl-dev/cal/password";
      htpasswd = "galaxy/lukasl-dev/cal/htpasswd";
    in
    [
      {
        age.secrets = {
          ${password} = {
            rekeyFile = ../../../secrets/galaxy/lukasl-dev/cal/password.age;
            generator.script = "alnum";
            intermediary = true;
          };

          ${htpasswd} = {
            rekeyFile = ../../../secrets/galaxy/lukasl-dev/cal/htpasswd.age;
            mode = "0444";
            generator = {
              dependencies = {
                password = config.age.secrets.${password};
              };
              script =
                { decrypt, deps, ... }:
                let
                  htpasswd = lib.getExe' pkgs.apacheHttpd "htpasswd";
                in
                ''
                  password="$(${decrypt} "${deps.password.file}")"
                  hash="$(printf '%s\n' "$password" | ${htpasswd} -niBC 10 ${username} | cut -d: -f2-)"
                  printf '%s:%s\n' ${username} "$hash"
                '';
            };
          };
        };
      }

      (lib.mkIf cal.enable {
        galaxy.lukasl-dev = {
          proxy.rules = [
            {
              type = "https";
              name = "cal";
              to.http = "http://${addresses.local}:${toString cal.port}";
            }
          ];

          bindMounts = [ age.secrets.${htpasswd}.path ];

          modules = [
            {
              services.radicale = {
                enable = true;

                settings = {
                  server = {
                    hosts = [ "${addresses.local}:${toString cal.port}" ];
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

              networking.firewall.allowedTCPPorts = [ cal.port ];
            }
          ];
        };
      })
    ]
  );
}
