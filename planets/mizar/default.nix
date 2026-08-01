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

    networking.dns.discoverable = true;

    hosting = {
      proxy = {
        enable = true;
        local = true;
      };

      hole.enable = true;
      home.enable = true;
      homunculus.enable = true;
      media.enable = true;
    };
  };
}
