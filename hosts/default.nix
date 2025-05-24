{ meta, pkgs, ... }:

{
  imports = [
    ./i18n.nix
    ./secrets.nix
    ./firewall.nix
    ./fonts.nix
    ./shell.nix
    ./users.nix

    ../nixosModules/networking/dns/cloudflare.nix
    ../nixosModules/networking/tailscale.nix

    ../nixosModules/nixos/caches
    ../nixosModules/nixos/home-manager.nix
    ../nixosModules/nixos/nix.nix

    ../nixosModules/security/gnupg.nix
    ../nixosModules/security/sops.nix

    ../nixosModules/system/restic.nix

    ../nixosModules/themes/catppuccin.nix

    ../nixosModules/virtualisations/docker.nix
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
