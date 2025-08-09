{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix

    ./services/anki-sync-server.nix
    ./services/freshrss.nix
    ./services/gitea.nix
    ./services/jellyfin.nix
    ./services/mealie.nix
    ./services/nextcloud.nix
    ./services/nginx.nix
    ./services/restic.nix
    ./services/traefik.nix
    ./services/vaultwarden.nix
  ];

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

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
