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

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];

  planet = {
    name = "vega";
    timeZone = "Europe/Vienna";

    attic = {
      enable = true;

      sops.token = "planets/vega/attic/token";

      # caches = {
      #   vega = {
      #     name = "vega";
      #     trusted-public-key = "vega:B57uOXZgdBLi/6kEAnfmoIpIg+V8/RjLvxQI6iVCtO8=";
      #   };
      # };
    };

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
      r2modman.enable = true;
    };

    development = {
      lean.enable = true;
      python.enable = true;
    };

    virtualisation = {
      libvirt = {
        enable = true;
        virt-manager.enable = true;
        winapps.enable = true;
        # domains = {
        #   RDPWindows = {
        #     source = ../../vms/RDPWindows.xml;
        #     autostart = false; # set to true if you want libvirt to autostart it
        #   };
        # };
      };
    };
  };
}
