{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    # ./kubernetes.nix
  ];

  networking.hostName = "sirius";

  boot = {
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;
}
