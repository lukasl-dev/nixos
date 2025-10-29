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
    enableIPv6 = true;
    defaultGateway = {
      address = ipv4.gateway;
      inherit interface;
    };
    defaultGateway6 = {
      address = ipv6.gateway;
      inherit interface;
    };

    interfaces.ens18 = {
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

      # ipv6 = {
      #   addresses = [
      #     {
      #       address = ipv6.address;
      #       prefixLength = ipv6.prefix;
      #     }
      #   ];
      #
      #   routes = [
      #     {
      #       address = "::";
      #       prefixLength = 0;
      #       via = ipv6.gateway;
      #     }
      #   ];
      # };
    };
  };
}
