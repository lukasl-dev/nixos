let
  interface = "ens18";
  ipv4 = {
    address = "185.245.61.227";
    prefix = 24;
    gateway = "185.245.61.1";
  };
  ipv6.gateway = "fe80::1";
in
{
  networking = {
    enableIPv6 = true;

    defaultGateway = {
      address = ipv4.gateway;
      inherit interface;
    };
    defaultGateway6 = {
      address = ipv6.gateway;
      inherit interface;
    };

    interfaces.${interface} = {
      useDHCP = false;

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
}
