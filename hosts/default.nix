{ pkgs, ... }:

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
    ../modules/catppuccin.nix
    ../modules/docker.nix
    # ../modules/nh.nix
    ../modules/sops.nix
    ../modules/restic.nix
  ];

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
  ];
}
