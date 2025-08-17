{
  imports = [
    ./hardware-configuration.nix
    ./acme.nix
    ./boot.nix
    ./networking.nix

    ./services/anki-sync-server.nix
    ./services/forgejo.nix
    # ./services/freshrss.nix
    # ./services/jellyfin.nix
    ./services/maddy.nix
    # ./services/mealie.nix
    # ./services/nextcloud.nix
    ./services/prometheus.nix
    # ./services/nginx.nix
    # ./services/restic.nix
    ./services/traefik.nix
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
}
