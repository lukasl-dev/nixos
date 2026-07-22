{
  planet = {
    name = "vega";
    stateVersion = "25.05";

    modules = [ ./hardware-configuration.nix ];

    hardware = {
      bluetooth.enable = true;
      nvidia.enable = true;
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
  };
}
