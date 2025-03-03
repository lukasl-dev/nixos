{ config, ... }:

{
  services.restic.backups = {
    local = {
      initialize = true;
      repository = "/var/backup/restic/local";
      paths = [
        "/var/lib/vaultwarden"
      ];
      passwordFile = config.sops.secrets."restic/secret".path;
    };
  };
}
