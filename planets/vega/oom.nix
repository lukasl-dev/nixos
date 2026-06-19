{
  # keep the desktop responsive under memory pressure: use compressed ram
  # first, then a real swapfile as slower backup capacity
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024; # MiB = 32 GiB
    }
  ];

  boot.kernel.sysctl = {
    # prefer compressed ram swap for desktop memory pressure, and avoid
    # costly swap readahead from zram
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
  };

  # kill runaway user processes before the whole machine locks up
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    extraArgs = [
      "--prefer"
      "^(chrome|chromium|firefox|electron|code|node|python[0-9.]*|java|nix|llama.*|ollama|cc1plus|clang.*|rustc|cargo|zig|ld|ld\\.lld|mold)$"

      "--avoid"
      "^(systemd|sshd|dbus|NetworkManager|Hyprland|waybar|nix-daemon)$"
    ];
  };

  # start after swap is activated so earlyoom sees the zram/swapfile totals at
  # startup and does not briefly operate as if the machine had no swap
  systemd.services.earlyoom.after = [ "swap.target" ];
}
