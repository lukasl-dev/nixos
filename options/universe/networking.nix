{ lib, ... }:

{
  networking.firewall.enable = lib.mkDefault true;
  # Be explicit: allow ICMP echo by default so hosts remain pingable
  # unless a machine opts out locally.
  networking.firewall.allowPing = lib.mkDefault true;
}
