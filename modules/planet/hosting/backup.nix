{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet.hosting) backup;
  inherit (atlas.hosting.backup) host;

  listenAddress = "127.0.0.1";
  port = 8000;
  username = "backup";

  token = atlas.secrets.universe [
    "backup"
    "token"
  ];
  htpasswd = atlas.secrets.universe [
    "backup"
    "htpasswd"
  ];
in
{
  options.planet.hosting.backup.enable = lib.mkEnableOption "Restic REST server";

  config = lib.mkIf backup.enable {
    age.secrets = {
      ${token} = {
        rekeyFile = ../../.. + "/secrets/${token}.age";
        generator.script = "alnum";
        intermediary = true;
      };

      ${htpasswd} = {
        rekeyFile = ../../.. + "/secrets/${htpasswd}.age";
        owner = "restic";
        group = "restic";
        mode = "0400";
        generator = {
          dependencies.token = age.secrets.${token};
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
              token="$(${decrypt} "${deps.token.file}")"
              hash="$(
                printf '%s\n' "$token" \
                  | ${htpasswdExe} -niBC 10 ${lib.escapeShellArg username} \
                  | ${pkgs.coreutils}/bin/cut -d: -f2-
              )"
              printf '%s:%s\n' ${lib.escapeShellArg username} "$hash"
            '';
        };
      };
    };

    services.restic.server = {
      enable = true;
      listenAddress = "${listenAddress}:${toString port}";
      htpasswd-file = age.secrets.${htpasswd}.path;
    };

    planet.hosting.proxy.rules.backup = {
      ingress.host = host;
      upstream.http.url = "http://${listenAddress}:${toString port}";
    };
  };
}
