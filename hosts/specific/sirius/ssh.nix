{
  services.openssh.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 22 ];
  };
}
