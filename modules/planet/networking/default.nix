{
  imports = [
    ./dns.nix
    ./mullvad.nix
  ];

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
    nftables.enable = true;
  };

  planet.roles.operator.groups = [ "networkmanager" ];
}
