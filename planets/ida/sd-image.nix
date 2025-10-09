{ lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];

  # sd-image enables a broad generic module set via hardware.enableAllHardware.
  # This includes modules not present in linuxPackages_rpi4. Force-disable it
  # to avoid missing-module failures during the modules-shrunk build.
  hardware.enableAllHardware = lib.mkForce false;

  sdImage = {
    compressImage = false;
    imageName = "ida.img";
    firmwareSize = 512;
  };
}
