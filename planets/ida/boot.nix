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
      "console=ttyS1,115200n8"
      "console=tty1"
    ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];

    zfs.forceImportRoot = false;
  };

  hardware.enableRedistributableFirmware = true;

  time.hardwareClockInLocalTime = false;
}
