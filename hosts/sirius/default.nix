{
  boot = {
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  networking = {
    hostName = "sirius";
    domain = "contaboserver.net";
  };

  services.openssh.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 22 ];
  };
}
