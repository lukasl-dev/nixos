{
  planet = {
    name = "vega";
    stateVersion = "25.05";

    modules = [
      ./audio.nix
      ./boot.nix
      ./hardware-configuration.nix
      ./nvidia.nix
      ./oom.nix
    ];

    steward = {
      traveller = ../../travellers/prime;
      groups = [
        "libvirtd"
        "libvirt"
        "kvm"
      ];
    };

    hardware = {
      bluetooth.enable = true;
      nvidia.enable = true;
    };

    desktop = {
      enable = true;

      hyprland.keyboardDebounce = {
        enable = true;
        devices = [
          "/dev/input/by-id/usb-MoErgo_Glove80_Left_moergo.com:GLV80-79A1B31B22F37483-event-kbd"
        ];
        deviceNames = [ "Glove80 Keyboard" ];
        keys = [ "KEY_O" ];
        thresholdMs = 30;
      };

      hyprland.monitors = {
        "DP-1" = {
          mode = "1920x1080@239.96";
          position = "0x0";
          scale = 1;
        };

        "HDMI-A-1" = {
          mode = "1920x1080@74.973";
          position = "1920x0";
          scale = 1;
        };
      };
    };

    networking = {
      dns.discoverable = true;
    };

    programs = {
      uxplay.enable = true;
    };

    gaming = {
      enable = true;
      minecraft.enable = true;
      r2modman.enable = true;
      steam.enable = true;
    };

    services = {
      flatpak.enable = true;
      printing.enable = true;
    };
  };
}
