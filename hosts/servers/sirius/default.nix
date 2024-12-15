{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    ./harmonia.nix
  ];

  networking.hostName = "sirius";

  boot = {
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;
}
