{
  networking.networkmanager = {
    enable = true;

    dns = "none";
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
}
