{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./sd-image.nix
  ];

  # match the working pi4 example: let the initrd module closure tolerate
  # modules that the rpi kernel does not ship (avoids shrink failures)
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

      backup = {
        enable = true;
        mode = "host";
        dataDir = "/mnt/external/restic";
      };

      hole = {
        enable = true;
        mode = "host";
      };
    };
  };
}
