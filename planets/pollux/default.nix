{
  imports = [
    ./hardware-configuration.nix
    ./acme.nix
    ./boot.nix
    ./networking.nix

    ./services/anki-sync-server.nix
    ./services/attic.nix
    ./services/forgejo.nix
    # ./services/freshrss.nix
    # ./services/jellyfin.nix
    ./services/maddy.nix
    # ./services/mealie.nix
    # ./services/nextcloud.nix
    # ./services/ntfy-sh.nix
    ./services/prometheus.nix
    # ./services/nginx.nix
    # ./services/restic.nix
    ./services/seafile.nix
    ./services/restic.nix
    ./services/traefik.nix
    # ./services/tuwunel.nix
    ./services/vaultwarden.nix
  ];

  planet = {
    name = "pollux";
    timeZone = "Europe/Berlin";
  };

  security.sudo = {
    enable = true;
    extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: ALL
    '';
  };

  # users.users.${user.name}.linger = true;
}
