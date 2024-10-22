{
  boot = {
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  networking = {
    hostname = "vmi628694";
    domain = "contaboserver.net";
  };

  services.openssh.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 22 ];
  };
}
