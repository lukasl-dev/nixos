{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ localsend ];

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      # LocalSend
      53317

      # RPIPlay
      7000
      7100
    ];

    allowedUDPPorts = [
      # LocalSend
      53317

      # RPIPlay
      6000
      6001
      7011
    ];
  };
}
