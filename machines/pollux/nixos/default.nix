{
  meta,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ../../../presets/server/nixos
    ./hardware-configuration.nix

    ../../../nixosModules/nixos/distributed/server.nix

    ./gitea.nix
    # ./kavita.nix
    # ./lecture-recorder.nix
    ./nextcloud.nix
    ./nginx.nix
    ./restic.nix
    ./traefik.nix
    ./vaultwarden.nix
    ./anki-sync-server.nix
  ];

  home-manager.users.${meta.user.name} = import ../home {
    inherit inputs pkgs pkgs-unstable;
  };

  boot = {
    loader.grub.device = "/dev/sda";
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  networking =
    let
      interface = "ens18";
      ipv4 = {
        address = "185.245.61.227";
        prefix = 24;

        gateway = "185.245.61.1";
      };
    in
    {
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
