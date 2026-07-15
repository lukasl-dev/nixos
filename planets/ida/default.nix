{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./boot.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./sonoff.nix
    ./sd-image.nix
    # ./storage.nix
    ./swap.nix
  ];

  planet = {
    name = "ida";
    timeZone = "Europe/Vienna";
    stateVersion = "26.05";

    sudo.password = false;

    networking.dns.discoverable = true;
  };

  galaxy = {
    # backup = {
    #   enable = true;
    #   dataDir = "/mnt/external/restic";
    # };

    home.enable = true;
    hole.enable = true;
  };
}
