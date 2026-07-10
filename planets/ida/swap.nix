{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 100;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
      priority = 10;
    }
  ];
}
