{ pkgs, ... }:

{
  imports = [
    ./i18n.nix
    ./firewall.nix
    ./fonts.nix
    ./secrets.nix
    ./shell.nix
    ./users.nix

    ../modules/dns/cloudflare.nix
    ../modules/nixos/home-manager.nix
    ../modules/nixos/nix.nix
    ../modules/catppuccin.nix
    ../modules/docker.nix
    ../modules/sops.nix
  ];

  environment.systemPackages = with pkgs; [
    gcc
    glib
    glibc
    cargo
    rustc
  ];
}
