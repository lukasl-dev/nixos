{ lib, ... }:

let
  prefer = lib.concatStrings [
    "^(chrome|chromium|firefox|electron|code|node|python[0-9.]*|"
    "java|nix|llama.*|ollama|cc1plus|clang.*|rustc|cargo|zig|"
    "ld|ld\\.lld|mold)$"
  ];

  avoid = lib.concatStrings [
    "^(systemd|sshd|dbus|NetworkManager|Hyprland|waybar|"
    "nix-daemon)$"
  ];
in
{
  # Use compressed RAM first, then a real swapfile as slower backup capacity.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
  };

  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    extraArgs = [
      "--prefer"

      prefer
      "--avoid"
      avoid
    ];
  };

  # Ensure EarlyOOM sees both swap tiers when it starts.
  systemd.services.earlyoom.after = [ "swap.target" ];
}
