{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelModules = [
      "nct6775"
      "coretemp"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiInstallAsRemovable = true;
      };
    };
    supportedFilesystems = {
      ntfs = true;
    };
  };

  planet = {
    name = "vega";
    timeZone = "Europe/Vienna";

    hardware = {
      bluetooth.enable = true;

      nvidia = {
        enable = true;
        cuda = true;
      };
    };

    wm = {
      enable = true;

      hyprland = {
        enable = true;
        monitors = [
          "DP-2, 1920x1080@239.96, 0x0, 1"
          "HDMI-A-1, 1920x1080@74.973, 1920x0, 1"
        ];
      };
    };

    audio.enable = true;

    programs = {
      anki.enable = true;
      uxplay.enable = true;
    };

    services = {
      mullvad.enable = true;
    };

    gaming = {
      enable = true;

      lutris.enable = true;
      bottles.enable = true;

      steam.enable = true;
      minecraft.enable = true;
    };

    development = {
      lean.enable = true;
      python.enable = true;
    };

    virtualisation = {
      libvirt = {
        enable = true;
        virt-manager.enable = true;
      };
      winapps.enable = true;
    };
  };
}
