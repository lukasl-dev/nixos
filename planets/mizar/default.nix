{
  planet = {
    name = "mizar";
    stateVersion = "26.05";

    modules = [
      ./boot.nix
      ./hardware-configuration.nix
      ./media.nix
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
      hole.enable = true;
      home.enable = true;
      media.enable = true;
    };
  };
}
