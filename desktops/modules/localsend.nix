{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ localsend ];

  networking.firewall = {
    allowedTCPPorts = [
      # LocalSend
      53317
    ];

    allowedUDPPorts = [
      # LocalSend
      53317
    ];
  };
}
