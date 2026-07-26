{
  planet = {
    name = "ida";
    stateVersion = "26.05";

    modules = [
      ./hardware-configuration.nix
      ./networking.nix
      ./rpi.nix
      ./swap.nix
      {
        security.sudo.wheelNeedsPassword = false;
      }
    ];

    steward = {
      traveller = ../../travellers/prime;
      groups = [ "kvm" ];
    };

    time.zone = "Europe/Vienna";

    networking.dns.discoverable = true;

    hosting = {
      hole.enable = true;
    };
  };
}
