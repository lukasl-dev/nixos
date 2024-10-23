{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = null;
      UseDns = true;
      PermitRootLogin = "yes";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 22 ];
  };
}
