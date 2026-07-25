{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet.hosting) cal;
  inherit (atlas.hosting.cal) host;

  listenAddress = "127.0.0.1";
  port = 5232;
  stateDir = "/var/lib/radicale";

  lukasPassword = atlas.secrets.universe [
    "cal"
    "accounts"
    "lukas"
  ];
  marioPassword = atlas.secrets.universe [
    "cal"
    "accounts"
    "mario"
  ];
  htpasswd = atlas.secrets.universe [
    "cal"
    "htpasswd"
  ];
in
{
  options.planet.hosting.cal.enable = lib.mkEnableOption "Radicale server";

  config = lib.mkIf cal.enable {
    age.secrets = {
      ${lukasPassword} = {
        rekeyFile = ../../.. + "/secrets/${lukasPassword}.age";
        generator.script = "alnum";
        intermediary = true;
      };

      ${marioPassword} = {
        rekeyFile = ../../.. + "/secrets/${marioPassword}.age";
        generator.script = "alnum";
        intermediary = true;
      };

      ${htpasswd} = {
        rekeyFile = ../../.. + "/secrets/${htpasswd}.age";
        owner = "radicale";
        group = "radicale";
        mode = "0400";
        generator = {
          dependencies = {
            lukasPassword = age.secrets.${lukasPassword};
            marioPassword = age.secrets.${marioPassword};
          };
          script =
            {
              decrypt,
              deps,
              pkgs,
              ...
            }:
            let
              htpasswdExe = lib.getExe' pkgs.apacheHttpd "htpasswd";
            in
            ''
              ${decrypt} "${deps.lukasPassword.file}" \
                | ${htpasswdExe} -niBC 10 lukas
              ${decrypt} "${deps.marioPassword.file}" \
                | ${htpasswdExe} -niBC 10 mario
            '';
        };
      };
    };

    services.radicale = {
      enable = true;

      settings = {
        server.hosts = [ "${listenAddress}:${toString port}" ];

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

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules.cal = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
