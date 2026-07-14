{
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 2;
      };
    };

    kernelParams = [
      "console=serial0,115200n8"
      "console=tty1"
    ];
    initrd.allowMissingModules = true;

    zfs.forceImportRoot = false;
  };

  hardware.enableRedistributableFirmware = true;

  time.hardwareClockInLocalTime = false;
}
