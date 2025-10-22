{
  imports = [
    ./hardware-configuration.nix
    ./acme.nix
    ./boot.nix
    ./networking.nix

    ./services/anki-sync-server.nix
    ./services/attic.nix
    ./services/capTUre.nix
    ./services/firefly.nix
    ./services/forgejo.nix
    ./services/freshrss.nix
    # ./services/jellyfin.nix
    ./services/maddy.nix
    # ./services/mealie.nix
    # ./services/nextcloud.nix
    ./services/ntfy-sh.nix
    ./services/prometheus.nix
    ./services/nginx.nix
    # ./services/restic.nix
    ./services/seafile.nix
    ./services/restic.nix
    # ./services/coturn.nix
    ./services/traefik.nix
    ./services/tuwunel.nix
    ./services/vaultwarden.nix
    ./services/www.nix
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];

  planet = {
    name = "pollux";
    timeZone = "Europe/Berlin";

    sudo.password = false;
  };

  # users.users.${user.name}.linger = true;
}
