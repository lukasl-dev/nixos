{
  networking.firewall = {
    enable = true;

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
