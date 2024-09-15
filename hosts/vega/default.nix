{
  imports = [
    ./hardware-configuration.nix

    ../../modules/system/hardware/bluetooth.nix
    ../../modules/programs/dconf.nix
    ../../modules/system/virtualisation/nvidia-containers.nix
    ../../modules/programs/gnome.nix
    ../../modules/system/desktop/hyprland.nix
    ../../modules/system/networking/dns.nix
    ../../modules/system/networking/firewall.nix
    ../../modules/system/graphics/nvidia.nix
    ../../modules/system/graphics/opengl.nix
    ../../modules/programs/ollama.nix
    ../../modules/system/sound.nix
    ../../modules/system/security/polkit.nix
    ../../modules/qt.nix
    ../../modules/gaming/steam.nix
    ../../modules/gaming/gamemode.nix
    ../../modules/gaming/gamescope.nix
    ../../modules/system/xserver.nix
  ];

  networking.hostName = "vega";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = {
    ntfs = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";

    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";

    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
  };
}
