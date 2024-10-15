{ pkgs-unstable, lib, ... }:

{
  environment.systemPackages = [ pkgs-unstable.rpiplay ];

  networking.firewall = {
    enable = lib.mkDefault true;

    allowedTCPPorts = [
      # RPIPlay
      7000
      7100
    ];

    allowedUDPPorts = [
      # RPIPlay
      6000
      6001
      7011
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
