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
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
    };
  };

  sops.secrets = {
    "planets/pollux/restic/secret" = { };
  };
}
