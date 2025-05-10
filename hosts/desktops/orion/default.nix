{ pkgs, ... }:

{
  imports = [
    ../default.nix
    ./hardware-configuration.nix

    ../../../modules/llms.nix
    ../../../modules/hardware/hp-wmi.nix
  ];

  boot = {
    kernelModules = [
      "nct6775"
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

  # https://forum.manjaro.org/t/pipewire-doesnt-detect-headphones-hp-laptop/92838
  environment.systemPackages = [
    pkgs.sof-firmware
    pkgs.alsa-ucm-conf
  ];

  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      TLP_DEFAULT_MODE = "BAT";
      TLP_PERSISTENT_DEFAULT = 1;
    };
  };
}
