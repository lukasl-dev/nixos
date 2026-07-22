{
  imports = [
    ./dns.nix
  ];

  networking = {
    firewall.enable = true;
    nftables.enable = true;
  };
}
