{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet.hosting) cache;
  inherit (config.services) atticd;
  inherit (atlas.hosting.cache) host;

  listenAddress = "127.0.0.1";
  port = 1571;
  stateDir = "/var/lib/atticd";

  serverToken = atlas.secrets.universe [
    "cache"
    "serverToken"
  ];
  environment = atlas.secrets.universe [
    "cache"
    "environment"
  ];
in
{
  options.planet.hosting.cache.enable =
    lib.mkEnableOption "Attic binary cache server";

  config = lib.mkIf cache.enable {
    age.secrets = {
      ${serverToken} = {
        rekeyFile = ../../.. + "/secrets/${serverToken}.age";
        intermediary = true;
      };

      ${environment} = {
        rekeyFile = ../../.. + "/secrets/${environment}.age";
        owner = atticd.user;
        group = atticd.group;
        mode = "0400";
        generator = {
          dependencies.token = age.secrets.${serverToken};
          script =
            { decrypt, deps, ... }:
            ''
              token="$(${decrypt} "${deps.token.file}")"
              printf \
                'ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=%s\n' \
                "$token"
            '';
        };
      };
    };

    services.atticd = {
      enable = true;
      environmentFile = age.secrets.${environment}.path;

      settings = {
        listen = "${listenAddress}:${toString port}";
        jwt = { };

        chunking = {
          nar-size-threshold = 64 * 1024;
          min-size = 16 * 1024;
          avg-size = 64 * 1024;
          max-size = 256 * 1024;
        };

        garbage-collection.default-retention-period = "14 days";
      };
    };

    users = {
      users.${atticd.user} = {
        isSystemUser = true;
        group = atticd.group;
      };
      groups.${atticd.group} = { };
    };

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules.cache = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
