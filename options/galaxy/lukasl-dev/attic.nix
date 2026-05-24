{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) domain attic;

  inherit (config.services) atticd;

  serverToken = "galaxy/lukasl-dev/attic/serverToken";
  env = "galaxy/lukasl-dev/attic/env";
in
{
  options.galaxy.lukasl-dev = {
    attic = {
      enable = lib.mkEnableOption "Enable Attic cache server";

      host = lib.mkOption {
        type = lib.types.str;
        default = "cache.${domain}";
        readOnly = true;
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 1571;
        readOnly = true;
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets = {
        ${serverToken} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/attic/serverToken.age;
          intermediary = true;
        };

        ${env} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/attic/env.age;
          generator = {
            dependencies = {
              token = age.secrets.${serverToken};
            };
            script =
              { decrypt, deps, ... }:
              # bash
              ''
                token="$(${decrypt} "${deps.token.file}")"

                cat <<EOF
                ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="$token"
                EOF
              '';
          };
        };
      };
    }

    (lib.mkIf attic.enable {
      galaxy.lukasl-dev.proxy.rules = [
        {
          type = "https";
          name = "cache";
          from.host = attic.host;
          to.http = "http://localhost:${toString attic.port}";
        }
      ];

      age.secrets.${env}.owner = atticd.user;

      services.atticd = {
        enable = true;

        environmentFile = age.secrets.${env}.path;

        settings = {
          listen = "[::]:${toString attic.port}";

          jwt = { };

          chunking = {
            nar-size-threshold = 64 * 1024;
            min-size = 16 * 1024;
            avg-size = 64 * 1024;
            max-size = 256 * 1024;
          };

          garbage-collection = {
            default-retention-period = "7 days";
          };
        };
      };

      users = {
        users.${atticd.user} = {
          isSystemUser = true;
          group = atticd.user;
        };

        groups.${atticd.user} = { };
      };

      planet.attic.endpoint = "https://${attic.host}";
    })
  ];
}
