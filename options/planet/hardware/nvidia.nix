{
  config,
  lib,
  pkgs,
  ...
}:

let
  nvidia = config.planet.hardware.nvidia;
in
{
  options.planet.hardware.nvidia = {
    enable = lib.mkEnableOption "Enable nvidia";

    cuda = lib.mkOption {
      type = lib.types.bool;
      description = "Enable cuda support";
      default = false;
      example = "true";
    };
  };

  config = lib.mkIf nvidia.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    boot = {
      initrd.kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];

      kernelParams = [
        # use the nvidia framebuffer device
        "nvidia_drm.fbdev=1"

        # required for stable suspend/resume
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"

        # save vram to disk instead of ram (tmpfs) to prevent resume failures
        "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      ];

      # boot.kernelModules = [ "nvidia" ];
      blacklistedKernelModules = [ "nouveau" ];
    };

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement = {
        enable = true;
        finegrained = false;
      };

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
    };

    environment.sessionVariables = lib.mkMerge [
      {
        GBM_BACKEND = "nvidia-drm";

        __GLX_VENDOR_LIBRARY_NAME = "nvidia";

        # hardware video acceleration
        LIBVA_DRIVER_NAME = "nvidia";

        # disable vsync
        __GL_SYNC_TO_VBLANK = "0";

        # lowest frame buffering -> lower latency
        __GL_MaxFramesAllowed = "1";

        # g-sync/vrr support
        __GL_GSYNC_ALLOWED = "1";
        __GL_VRR_ALLOWED = "1";

        __GL_YIELD = "USLEEP";

        __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
      }
    ];

    environment.systemPackages = with pkgs; [
      nvidia-vaapi-driver
      vulkan-headers
      vulkan-tools
      vulkan-loader
      dxvk

      nvtopPackages.nvidia
    ];
  };
}
