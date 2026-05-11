{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    kernelModules = [
      "nct6775"
      "coretemp"
    ];
    kernel.sysctl = {
      "user.max_user_namespaces" = 15000;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiInstallAsRemovable = true;
      };
    };
    supportedFilesystems.ntfs = true;
  };

  planet = {
    name = "vega";
    timeZone = "Europe/Vienna";
    stateVersion = "25.05";

    hardware = {
      bluetooth.enable = true;

      nvidia = {
        enable = true;
        cuda = true;
      };
    };

    display = {
      enable = true;

      hyprland = {
        enable = true;
        monitors = [
          {
            output = "DP-2";
            mode = "1920x1080@239.96";
            position = "0x0";
            scale = 1;
          }
          {
            output = "HDMI-A-1";
            mode = "1920x1080@74.973";
            position = "1920x0";
            scale = 1;
          }
        ];
      };
    };

    programs = {
      anki.enable = true;
      uxplay.enable = true;
    };

    services = {
      flatpak.enable = true;
      printing.enable = true;
    };

    networking = {
      dns.discoverable = true;
      mullvad.enable = true;
    };

    gaming = {
      enable = true;

      steam.enable = true;
      minecraft.enable = true;
      r2modman.enable = true;
    };
  };
}
