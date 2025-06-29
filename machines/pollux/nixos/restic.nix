{ config, ... }:

{
  services.restic.backups = {
    local = {
      initialize = true;
      repository = "/var/backup/restic/local";
      paths = [
        "/var/lib/vaultwarden"
        (config.services.nextcloud.datadir)
      ];
      passwordFile = config.sops.secrets."restic/secret".path;
    };
  };

  sops.secrets = {
    "restic/secret" = { };
  };
}
