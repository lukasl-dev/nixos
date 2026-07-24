{
  planet = {
    name = "ida";
    stateVersion = "26.05";

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
