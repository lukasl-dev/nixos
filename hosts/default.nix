{
  imports = [
    ./i18n.nix
    ./firewall.nix
    ./shell.nix
    ./users.nix

    ../modules/dns/cloudflare.nix
    ../modules/nixos/home-manager.nix
    ../modules/nixos/nix.nix
    ../modules/catppuccin.nix
    ../modules/docker.nix
  ];
}
