{
  config,
  inputs,
  lib,
  ...
}:

let
  rpi = inputs.nixos-raspberrypi;
in
{
  imports = [
    # Vendor kernel, firmware, and Raspberry Pi packages.
    rpi.lib.inject-overlays
    rpi.nixosModules.nixpkgs-rpi

    # Make the project's binary cache available on ida as well as during
    # flake evaluation (the latter is configured in flake.nix).
    rpi.nixosModules.trusted-nix-caches

    rpi.nixosModules.raspberry-pi-4.base
    rpi.nixosModules.sd-image
  ];

  boot = {
    loader.raspberry-pi = {
      # Keep kernel, initrd, and device trees together per NixOS generation.
      # Migrating an existing U-Boot installation requires preparing and
      # backing up the firmware partition before switching.
      bootloader = "kernel";
      configurationLimit = 2;
    };

    initrd.allowMissingModules = true;
    supportedFilesystems.zfs = lib.mkForce false;
    zfs.forceImportRoot = false;
  };

  sdImage.compressImage = false;
  image.fileName = "ida.img";

  system.nixos.tags = [
    "raspberry-pi-${config.boot.loader.raspberry-pi.variant}"
    config.boot.loader.raspberry-pi.bootloader
    config.boot.kernelPackages.kernel.version
  ];

  time.hardwareClockInLocalTime = false;
}
