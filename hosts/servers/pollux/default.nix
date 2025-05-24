let
  interface = "ens18";
  ipv4 = {
    address = "185.245.61.227";
    prefix = 24;

    gateway = "185.245.61.1";
  };
in
{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    ./auto-update.nix
    ./lecture-recorder.nix
    ./nextcloud.nix
    ./nginx.nix
    ./postgres.nix
    ./restic.nix
    ./traefik.nix
    ./vaultwarden.nix

    ../../../modules/distributed/server.nix
  ];

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  # TODO: configure IPV6
  networking = {
    defaultGateway = {
      address = ipv4.gateway;
      interface = interface;
    };

    interfaces.ens18 = {
      useDHCP = false;

      ipv4 = {
        addresses = [
          {
            address = ipv4.address;
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
