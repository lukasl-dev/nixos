# Temporary/standalone Ethernet segment for the SONOFF Dongle Max.
#
# Wiring:
#   ida USB  -> SONOFF USB-C      (Zigbee serial + power)
#   ida end0 -> SONOFF Ethernet   (web UI / firmware / network features)
#   ida wlan0 remains the upstream LAN/internet connection.
{
  networking = {
    interfaces.end0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.50.1";
          prefixLength = 24;
        }
      ];
    };

    nat = {
      enable = true;
      internalInterfaces = [ "end0" ];
      externalInterface = "wlan0";
    };

    firewall.interfaces.end0.allowedUDPPorts = [ 67 ];
  };

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [ "end0" ];
      lease-database = {
        type = "memfile";
        persist = true;
        name = "/var/lib/kea/dhcp4.leases";
      };
      valid-lifetime = 43200;
      subnet4 = [
        {
          id = 1;
          subnet = "192.168.50.0/24";
          pools = [ { pool = "192.168.50.10 - 192.168.50.50"; } ];
          option-data = [
            {
              name = "routers";
              data = "192.168.50.1";
            }
            {
              name = "domain-name-servers";
              data = "1.1.1.1, 8.8.8.8";
            }
          ];
        }
      ];
    };
  };
}
