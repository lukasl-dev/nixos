{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware = {
    enableRedistributableFirmware = true;
  };

  boot = {
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    kernelParams = [
      "console=ttyS1,115200n8"
      "console=tty1"
    ];
  };

  networking = {
    networkmanager.enable = true;
  };

  time.hardwareClockInLocalTime = false;

  planet = {
    name = "ida";
    timeZone = "Europe/Vienna";

    sudo.password = false;
  };
}
