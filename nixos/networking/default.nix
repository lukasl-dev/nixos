{
  imports = [ ./firewall.nix ];

  networking.networkmanager = {
    enable = true;
    dns = "none";
  };

  # Cloudflare DNS
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
}
