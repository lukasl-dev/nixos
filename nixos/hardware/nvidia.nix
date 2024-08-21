{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nvidia = {
    enable = lib.mkOption {
      type = with lib.types; bool;
      default = true;
      description = "Enable the NVIDIA driver";
    };

    version = lib.mkOption {
      type = with lib.types; str;
      default = "555.58";
      description = "The version of the NVIDIA driver to use";
    };

    sha256_64bit = lib.mkOption {
      type = with lib.types; str;
      default = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
      description = "The SHA256 hash of the 64-bit NVIDIA driver";
    };

    sha256_aarch64 = lib.mkOption {
      type = with lib.types; str;
      default = lib.fakeSha256;
      description = "The SHA256 hash of the aarch64 NVIDIA driver";
    };

    openSha256 = lib.mkOption {
      type = with lib.types; str;
      default = lib.fakeSha256;
      description = "The SHA256 hash of the Open-Source NVIDIA driver";
    };

    persistencedSha256 = lib.mkOption {
      type = with lib.types; str;
      default = lib.fakeSha256;
      description = "The SHA256 hash of the persistenced NVIDIA driver";
    };
  };

  hardware.nvidia = lib.mkIf config.nvidia.enable {
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = false;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = config.nvidia.version;
      sha256_64bit = config.nvidia.sha256_64bit;
      sha256_aarch64 = config.nvidia.sha256_aarch64;
      openSha256 = config.nvidia.openSha256;
      settingsSha256 = config.nvidia.persistencedSha256;
      persistencedSha256 = config.nvidia.persistencedSha256;
    };
  };

  environment.systemPackages = lib.mkIf config.nvidia.enable (with pkgs; [ nvtopPackages.full ]);

  environment.sessionVariables = lib.mkIf config.nvidia.enable {
    "LIBVA_DRIVER_NAME" = "nvidia";
    "GBM_BACKEND" = "nvidia-drm";
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    "WLR_NO_HARDWARE_CURSORS" = "1";
  };
}
