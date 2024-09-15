{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nvidia-containers.nix
    ../../modules/gnome-keyring.nix
    ../../modules/seahorse.nix
    ../../modules/nautilus.nix
    ../../modules/hyprland.nix
    ../../modules/nvidia.nix
    ../../modules/opengl.nix
    ../../modules/ollama.nix
    ../../modules/pipewire.nix
    ../../modules/polkit.nix
    ../../modules/qt.nix
    ../../modules/steam.nix
    ../../modules/xserver.nix
    ../../modules/sddm.nix
  ];

  networking.hostName = "vega";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = {
      ntfs = true;
    };
  };

  home-manager.users = {
    lukas = import ../../home/lukas {
      inherit inputs pkgs pkgs-unstable;

      host = {
        # TODO: add config options for home manager modules
      };
    };
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
