{ config, ... }:

{
  services.restic.backups = {
    pollux = {
      initialize = true;
      repository = "rest:https://restic.lukasl.dev/pollux";
      passwordFile = config.sops.secrets."planets/pollux/restic/secret".path;
      paths = [
        "/var/lib"
        "/var/www"
      ];
      exclude = [
        "/var/lib/attic"
        "/var/lib/capTUre"
      ];
      pruneOpts = [ "--keep-daily 14" ];
    };
  };

  sops.secrets = {
    "planets/pollux/restic/secret" = { };
  };
}
