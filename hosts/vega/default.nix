{
  imports = [ 
    ./hardware-configuration.nix

    ../../nixos/1password
    ../../nixos/bluetooth
    ../../nixos/catppuccin
    ../../nixos/docker
    ../../nixos/gnome
    ../../nixos/hyprland
    ../../nixos/fonts
    ../../nixos/i18n
    ../../nixos/nix-ld
    ../../nixos/nvidia
    ../../nixos/pipewire
    ../../nixos/polkit
    ../../nixos/users
    ../../nixos/xserver
  ];
  
  system.stateVersion = "24.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];

    trusted-users = [
      "root"
      "lukas"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  
  networking.hostName = "vega";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # move to nix-ld
  # environment.sessionVariables = {
  #   WLR_NO_HARDWARE_CURSORS = "1";
  #   NIXOS_OZONE_WL = "1";
  #
  #   XDG_CACHE_HOME = "$HOME/.cache";
  #   XDG_CONFIG_HOME = "$HOME/.config";
  #   XDG_DATA_HOME = "$HOME/.local/share";
  #   XDG_STATE_HOME = "$HOME/.local/state";
  # };
  #
  # environment.variables = {
  #   LIBVA_DRIVER_NAME = "nvidia";
  #   GBM_BACKEND = "nvidia-drm";
  #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #
  #   MOZ_ENABLE_WAYLAND = "1";
  #   XDG_SESSION_TYPE = "wayland";
  #   GDK_BACKEND = "wayland";
  # };
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";

    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    LD_LIBRARY_PATH = [ "/run/current-system/sw/share/nix-ld/lib:$NIX_LD_LIBRARY_PATH" ];
  };

  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
  };
}
