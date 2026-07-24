{
  imports = [
    ./dns.nix
  ];

  networking = {
    firewall.enable = true;
    nftables.enable = true;
  };

  planet =
    let
      group = "networkmanager";
    in
    {
      steward.groups = [ group ];
      roles.operator.groups = [ group ];
    };
}
