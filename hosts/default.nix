{ meta, pkgs, ... }:

{
  imports = [
    ./i18n.nix
    ./secrets.nix
    ./firewall.nix
    ./fonts.nix
    ./shell.nix
    ./users.nix

    ../modules/dns/cloudflare.nix
    ../modules/nixos/home-manager.nix
    ../modules/nixos/nix.nix
    ../modules/virtualisation/docker.nix
    ../modules/catppuccin.nix
    ../modules/gnupg.nix
    ../modules/sops.nix
    ../modules/tailscale.nix
    ../modules/restic.nix
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
