{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet.hosting) waka;
  inherit (atlas.hosting.waka) host;

  listenAddress = "127.0.0.1";
  port = 3000;
  stateDir = "/var/lib/private/wakapi";

  salt = atlas.secrets.universe [
    "waka"
    "salt"
  ];
  env = atlas.secrets.universe [
    "waka"
    "env"
  ];
in
{
  options.planet.hosting.waka.enable = lib.mkEnableOption "Wakapi server";

  config = lib.mkIf waka.enable {
    age.secrets = {
      ${salt} = {
        rekeyFile = ../../.. + "/secrets/${salt}.age";
        intermediary = true;
      };

      ${env} = {
        rekeyFile = ../../.. + "/secrets/${env}.age";
        mode = "0400";
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

    services.wakapi = {
      enable = true;
      environmentFiles = [ age.secrets.${env}.path ];

      settings = {
        server = {
          public_url = "https://${host}";
          listen_ipv4 = listenAddress;
          inherit port;
        };

        security = {
          insecure_cookies = false;
          allow_signup = false;
        };
      };
    };

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules.waka = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
