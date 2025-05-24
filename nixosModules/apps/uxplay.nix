{ pkgs-unstable, ... }:

{
  environment.systemPackages = [ pkgs-unstable.uxplay ];

  networking.firewall = {
    allowedTCPPorts = [
      7000
      7100
      4000
      4001
    ];

    allowedUDPPorts = [
      6000
      6001
      7011
      5353
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };
}
