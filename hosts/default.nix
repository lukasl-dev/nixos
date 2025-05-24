{ meta, pkgs, ... }:

{
  imports = [
    ./i18n.nix
    ./secrets.nix
    ./firewall.nix
    ./fonts.nix
    ./shell.nix
    ./users.nix

    ../modules/networking/dns/cloudflare.nix
    ../modules/networking/tailscale.nix

    ../modules/security/gnupg.nix
    ../modules/security/sops.nix

    ../modules/system/restic.nix

    ../modules/virtualisations/docker.nix

    ../modules/nixos/home-manager.nix
    ../modules/nixos/nix.nix
    ../modules/catppuccin.nix
  ];

  networking.hostName = meta.hostName;

  environment.systemPackages = with pkgs; [
    nvd

    gcc
    glib
    glibc
    cargo
    rustc
    nil
    file
    cron
    screen
  ];
}
