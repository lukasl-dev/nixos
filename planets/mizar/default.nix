{
  planet = {
    name = "mizar";
    stateVersion = "26.05";

    modules = [
      ./boot.nix
      ./hardware-configuration.nix
      ./networking.nix
      {
        security.sudo.wheelNeedsPassword = false;
      }
    ];

    steward = {
      traveller = ../../travellers/prime;
      groups = [ "kvm" ];
    };

    networking = {
      dns.discoverable = true;
    };

    hosting = {
      home.enable = true;
      media.enable = true;
    };
  };
}
