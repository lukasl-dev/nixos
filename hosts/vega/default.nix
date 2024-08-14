{
  imports = [ 
    ./hardware-configuration.nix

    ../../nixos/1password
    ../../nixos/bluetooth
    ../../nixos/boot
    ../../nixos/catppuccin
    ../../nixos/dconf
    ../../nixos/docker
    ../../nixos/gnome
    ../../nixos/hyprland
    ../../nixos/fonts
    ../../nixos/i18n
    ../../nixos/networking
    ../../nixos/nix
    ../../nixos/nix-ld
    ../../nixos/nvidia
    ../../nixos/ollama
    ../../nixos/pipewire
    ../../nixos/polkit
    ../../nixos/qt
    ../../nixos/steam
    ../../nixos/users
    ../../nixos/xserver
  ];
  
  networking.hostName = "vega";

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";

    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";

    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
  };
}
