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
        version = "590.48.01";
        sha256_64bit = "sha256-ueL4BpN4FDHMh/TNKRCeEz3Oy1ClDWto1LO/LWlr1ok=";
        openSha256 = "sha256-hECHfguzwduEfPo5pCDjWE/MjtRDhINVr4b1awFdP44=";
        settingsSha256 = "sha256-NWsqUciPa4f1ZX6f0By3yScz3pqKJV1ei9GvOF8qIEE=";
        sha256_aarch64 = lib.fakeSha256;
        persistencedSha256 = lib.fakeSha256;
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
