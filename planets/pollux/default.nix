{
  planet = {
    name = "pollux";
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
  };
}
