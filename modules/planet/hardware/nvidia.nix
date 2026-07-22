{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
in
{
  options.planet.hardware.nvidia = {
    enable = lib.mkEnableOption "NVIDIA support";
  };

  config = lib.mkIf planet.hardware.nvidia.enable {
    nixpkgs.config.cudaSupport = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    # load the driver early so drm/kms is ready before hyprland starts
    boot.initrd.kernelModules = [
      # core gpu driver
      "nvidia"

      # display engine and mode setting
      "nvidia_modeset"

      # unified memory used by cuda and compute workloads
      "nvidia_uvm"

      # drm/kms integration required by wayland compositors
      "nvidia_drm"
    ];

    hardware = {
      nvidia = {
        modesetting.enable = true;
        open = true;
        nvidiaSettings = false;

        package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "595.58.03";
          sha256_64bit = "sha256-jA1Plnt5MsSrVxQnKu6BAzkrCnAskq+lVRdtNiBYKfk=";
          openSha256 = "sha256-6LvJyT0cMXGS290Dh8hd9rc+nYZqBzDIlItOFk8S4n8=";
          settingsSha256 = "sha256-2vLF5Evl2D6tRQJo0uUyY3tpWqjvJQ0/Rpxan3NOD3c=";
          sha256_aarch64 = "sha256-hzzIKY1Te8QkCBWR+H5k1FB/HK1UgGhai6cl3wEaPT8=";
          persistencedSha256 = "sha256-AtjM/ml/ngZil8DMYNH+P111ohuk9mWw5t4z7CHjPWw=";
        };

        # save vram to disk rather than a size-limited tmpfs during suspend
        moduleParams.nvidia.NVreg_TemporaryFilePath = "/var/tmp";

        powerManagement = {
          enable = true;
          finegrained = false;
        };
      };
    };

    environment = {
      sessionVariables = {
        # select the nvidia va-api compatibility driver
        LIBVA_DRIVER_NAME = "nvidia";

        # use the backend recommended for current nvidia drivers
        NVD_BACKEND = "direct";

        # route glx applications, including xwayland clients, to nvidia
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

      systemPackages = with pkgs; [
        nvtopPackages.nvidia
      ];
    };
  };
}
