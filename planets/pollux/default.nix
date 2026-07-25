{
  planet = {
    name = "pollux";
    stateVersion = "25.05";

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
      groups = [
        "libvirtd"
        "libvirt"
        "kvm"
      ];
    };

    time.zone = "Europe/Berlin";

    backup.enable = true;

    hosting = {
      proxy.enable = true;

      anki.enable = true;
      books.enable = true;
      cache.enable = true;
      cal.enable = true;
      forge.enable = true;
      household.enable = true;
      homunculus.enable = true;
      mail.enable = true;
      matrix.enable = true;
      notes.enable = true;
      vault.enable = true;
      waka.enable = true;
      www.enable = true;
      yam.enable = true;
    };
  };
}
