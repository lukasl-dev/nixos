{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware = {
    enableRedistributableFirmware = true;
  };

  boot = {
    loader.generic-extlinux-compatible.enable = true;
    kernelParams = [
      "console=ttyAMA0,115200n8"
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
