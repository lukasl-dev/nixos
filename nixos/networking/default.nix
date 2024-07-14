{
  imports = [
    ./firewall.nix
  ];

  networking.networkmanager.enable = true;

  # Cloudflare DNS
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
}
