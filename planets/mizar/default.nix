{
  planet = {
    name = "mizar";
    stateVersion = "26.05";

    modules = [
      ./boot.nix
      ./hardware-configuration.nix
    ];

    steward = {
      traveller = ../../travellers/prime;
      groups = [ "kvm" ];
    };

    networking = {
      dns.discoverable = true;
    };
  };
}
