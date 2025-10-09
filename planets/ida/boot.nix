{ pkgs, ... }:

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
    kernelPackages = pkgs.linuxPackages_rpi4;
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];

    deviceTree = {
      kernelPackage = pkgs.linuxKernel.kernels.linux_rpi4;
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  time.hardwareClockInLocalTime = false;
}
