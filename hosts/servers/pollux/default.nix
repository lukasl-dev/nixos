{
  imports = [
    ../default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "pollux";

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  networking = {
    defaultGateway = {
      address = "185.245.61.1";
      interface = "ens18";
    };

    interfaces.ens18 = {
      useDHCP = true;

      ipv4 = {
        addresses = [
          {
            address = "185.245.61.227";
            prefixLength = 24;
          }
        ];
      };
    };
  };
}
