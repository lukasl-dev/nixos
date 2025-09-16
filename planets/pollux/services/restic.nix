{ config, ... }:

{
  services.restic.backups = {
    local = {
      initialize = true;
      repository = "/var/backup/restic/local";
      paths = [ "/var/lib" ];
      passwordFile = config.sops.secrets."planets/pollux/restic/secret".path;
    };
  };

  sops.secrets = {
    "planets/pollux/restic/secret" = { };
  };
}
