{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./sd-image.nix
  ];

  # Match the working Pi4 example: let the initrd module closure tolerate
  # modules that the RPi kernel does not ship (avoids shrink failures).
  nixpkgs.overlays = [
    (
      final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      }
    )
  ];

  planet = {
    name = "ida";
    timeZone = "Europe/Vienna";

    sudo.password = false;
  };
}
