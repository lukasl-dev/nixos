{ pkgs, ... }:

{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    ../../../modules/llms.nix
  ];

  networking.hostName = "orion";

  boot = {
    kernelModules = [
      "nct6775"
      "hp-wmi"
      "coretemp"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = {
      ntfs = true;
    };
  };

  # TODO: this is highly likely redundant

  environment.sessionVariables = {
    WWLR_NO_HARDWARE_CURSORSLR_NO_HARDWARE_CURSORS = "1";

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

  # https://forum.manjaro.org/t/pipewire-doesnt-detect-headphones-hp-laptop/92838
  environment.systemPackages = [
    pkgs.sof-firmware
    pkgs.alsa-ucm-conf
  ];

  # TODO: move to separate module for all desktops
  programs.coolercontrol = {
    enable = true;
    nvidiaSupport = true;
  };
}
