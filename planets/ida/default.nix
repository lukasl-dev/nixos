{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./boot.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./sonoff.nix
    ./sd-image.nix
    ./storage.nix
    ./swap.nix
  ];

  # Match the working Pi 4 example: let the initrd module closure tolerate
  # modules that the Raspberry Pi vendor kernel does not ship.
  nixpkgs.overlays = [
    (_: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  planet = {
    name = "ida";
    timeZone = "Europe/Vienna";
    stateVersion = "25.05";

    sudo.password = false;

    networking.dns.discoverable = true;
  };

  galaxy = {
    acme = {
      enable = true;
      email = "contact@lukasl.dev";
    };

    lukasl-dev = {
      enable = true;
      mode = "host";

      backup = {
        enable = true;
        dataDir = "/mnt/external/restic";
      };

      home.enable = true;
      hole.enable = true;
    };
  };
}
