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
        "networkmanager"
        "wheel"
        "docker"
        "libvirtd"
        "libvirt"
        "kvm"
      ];
    };

    hardware = {
      bluetooth.enable = true;
      nvidia.enable = true;
    };

    desktop.enable = true;

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
