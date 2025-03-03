{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    ./harmonia.nix
    ./nextcloud.nix
    ./restic.nix
    ./traefik.nix
    ./vaultwarden.nix
  ];

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  networking = {
    hostName = "pollux";

    defaultGateway = {
      address = "185.245.61.1";
      interface = "ens18";
    };

    interfaces.ens18 = {
      useDHCP = false;

      ipv4 = {
        addresses = [
          {
            address = "185.245.61.227";
            prefixLength = 24;
          }
        ];

        routes = [
          {
            address = "0.0.0.0";
            prefixLength = 0;
            via = "185.245.61.1";
          }
        ];
      };
    };
  };
}
