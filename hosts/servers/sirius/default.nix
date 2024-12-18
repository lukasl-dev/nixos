{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    ./harmonia.nix
    ./traefik.nix
    ./vaultwarden.nix
  ];

  networking.hostName = "sirius";

  boot = {
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;
}
