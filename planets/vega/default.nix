{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    limine = {
      enable = true;
      efiInstallAsRemovable = true;
    };
  };

  planet = {
    name = "vega";
    stateVersion = "25.05";

    modules = [ ./hardware-configuration.nix ];

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

    networking.dns.discoverable = true;

    programs.uxplay.enable = true;

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
