{ config, ... }:

{
  services.restic.backups = {
    local = {
      initialize = true;
      repository = "/var/backup/restic/local";
      passwordFile = config.sops.secrets."planets/pollux/restic/secret".path;
      paths = [
        "/var/lib"
        "/var/www"
      ];
      exclude = [ "var/lib/attic" ];
    };
  };

  sops.secrets = {
    "planets/pollux/restic/secret" = { };
  };
}
