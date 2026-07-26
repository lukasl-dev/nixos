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
    rpi.lib.inject-overlays
    rpi.nixosModules.nixpkgs-rpi
    rpi.nixosModules.trusted-nix-caches
    rpi.nixosModules.raspberry-pi-4.base
    rpi.nixosModules.sd-image
  ];

  boot = {
    loader.raspberry-pi = {
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
