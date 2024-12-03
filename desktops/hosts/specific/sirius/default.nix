{
  imports = [
    ./hardware-configuration.nix
    ../../base/unspecific

    ./packages.nix
    ./ssh.nix
  ];

  boot = {
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  networking = {
    hostName = "sirius";
    domain = "lukasl.dev";
  };

  virtualisation.oci-containers = {
    backend = "docker";
  };

  networking.firewall.allowedTCPPorts = [ 6379 ];
}
