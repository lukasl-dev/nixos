{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    # ./github-runners.nix
    ./harmonia.nix
    ./koodo-reader.nix
    # ./mail.nix
    ./traefik.nix
    ./vaultwarden.nix
  ];

  networking.hostName = "sirius";

  boot = {
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;
}
