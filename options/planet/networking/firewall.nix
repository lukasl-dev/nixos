{ lib, ... }:

{
  networking = {
    firewall.enable = lib.mkDefault true;
    nftables.enable = lib.mkDefault true;
  };
}
