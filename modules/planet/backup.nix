{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) backup name;
  inherit (atlas.hosting.backup) host;

  token = atlas.secrets.universe [
    "backup"
    "token"
  ];
  password = atlas.secrets.universe [
    "backup"
    "password"
  ];
  env = atlas.secrets.universe [
    "backup"
    "env"
  ];
in
{
  options.planet.backup = {
    enable = lib.mkEnableOption "backup client";

    dirs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Directories included in this planet's backup.";
    };
  };

  config = lib.mkIf backup.enable {
    age.secrets = {
      ${token} = {
        rekeyFile = ../.. + "/secrets/${token}.age";
        generator.script = "alnum";
        intermediary = true;
      };

      ${password} = {
        rekeyFile = ../.. + "/secrets/${password}.age";
        mode = "0400";
      };

      ${env} = {
        rekeyFile = ../.. + "/secrets/${env}.age";
        mode = "0400";
        generator = {
          dependencies.token = age.secrets.${token};
          script =
            { decrypt, deps, ... }:
            ''
              token="$(${decrypt} "${deps.token.file}")"
              printf 'RESTIC_REST_USERNAME=backup\n'
              printf 'RESTIC_REST_PASSWORD=%s\n' "$token"
            '';
        };
      };
    };

    services.restic.backups.${name} = {
      initialize = true;
      repository = "rest:https://${host}/${name}";
      environmentFile = age.secrets.${env}.path;
      passwordFile = age.secrets.${password}.path;
      paths = lib.unique backup.dirs;
      pruneOpts = [ "--keep-daily 14" ];
    };
  };
}
