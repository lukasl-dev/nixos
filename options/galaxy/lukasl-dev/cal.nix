{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) addresses cal;

  isGuest = cal.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/radicale";
in
{
  options.galaxy.lukasl-dev = {
    cal = {
      enable = lib.mkEnableOption "Enable radicale server";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run radicale in the lukasl-dev container or on the host.";
      };

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

        networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ cal.port ];
      };
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
                  password="$(${decrypt} "${deps.password.file}")"
                  hash="$(printf '%s\n' "$password" | ${htpasswd} -niBC 10 ${username} | cut -d: -f2-)"
                  printf '%s:%s\n' ${username} "$hash"
                '';
            };
          };
        };
      }

      (lib.mkIf cal.enable (
        lib.mkMerge [
          {
            galaxy.lukasl-dev = {
              proxy.rules = [
                {
                  type = "https";
                  name = "cal";
                  to.http = "http://${listenAddress}:${toString cal.port}";
                }
              ];

              backup.paths = [
                (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
              ];

              bindMounts = lib.mkIf isGuest [ age.secrets.${htpasswd}.path ];

              modules.cal = {
                inherit (cal) mode;
                inherit module;
              };
            };
          }

          (lib.mkIf (!isGuest) module)
        ]
      ))
    ]
  );
}
