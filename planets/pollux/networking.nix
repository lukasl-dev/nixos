let
  interface = "ens18";
  ipv4 = {
    address = "185.245.61.227";
    prefix = 24;

    gateway = "185.245.61.1";
  };
  ipv6 = {
    prefix = 64;
    address = "2a13:7e80:0:b2::1";
    gateway = "fe80::1";
  };
in
{
  networking = {
    # IPv4: keep static config as-is
    enableIPv6 = false; # fully disable IPv6 for now (was half-enabled)
    defaultGateway = {
      address = ipv4.gateway;
      inherit interface;
    };

    # Do NOT declare defaultGateway6 when IPv6 addressing is disabled; it
    # can cause resolver/egress stalls and odd timeouts.

    # Use networkd for static config and disable NetworkManager to avoid DNS races.
    useNetworkd = true;
    networkmanager.enable = false;

    interfaces.ens18 = {
      useDHCP = false;

      # Temporary MTU mitigation in case the provider added a tunnel/scrubber
      # that lowered path MTU and blocks ICMP "frag needed". This avoids
      # blackhole stalls on TLS/SSH handshakes.
      mtu = 1400;

      ipv4 = {
        addresses = [
          {
            inherit (ipv4) address;
            prefixLength = ipv4.prefix;
          }
        ];

        routes = [
          {
            address = "0.0.0.0";
            prefixLength = 0;
            via = ipv4.gateway;
          }
        ];
      };
    };
  };

  # Also enable TCP MTU probing in case of PMTU blackholes.
  boot.kernel.sysctl = {
    "net.ipv4.tcp_mtu_probing" = 1; # try probing when loss is detected
  };

  # Prefer systemd-resolved managing DNS; nameservers come from
  # options/planet/networking/dns.nix (Cloudflare/Google).
  services.resolved.enable = true;
}
