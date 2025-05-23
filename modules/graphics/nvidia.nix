{
  pkgs,
  lib,
  config,
  ...
}:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.initrd.kernelModules = [ "nvidia" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement = {
      enable = true;
      finegrained = false;
    };

    open = true;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "575.51.02";
      sha256_64bit = "sha256-XZ0N8ISmoAC8p28DrGHk/YN1rJsInJ2dZNL8O+Tuaa0=";
      openSha256 = "sha256-NQg+QDm9Gt+5bapbUO96UFsPnz1hG1dtEwT/g/vKHkw=";
      settingsSha256 = "sha256-VUetj3LlOSz/LB+DDfMCN34uA4bNTTpjDrb6C6Iwukk=";
      sha256_aarch64 = lib.fakeSha256;
      persistencedSha256 = lib.fakeSha256;
    };
  };

  environment.sessionVariables = lib.mkMerge [
    {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";

      # disable vsync
      __GL_SYNC_TO_VBLANK = "0";

      # lowest frame buffering -> lower latency
      __GL_MaxFramesAllowed = "1";

      __GL_YIELD = "USLEEP";

      __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    }
  ];

  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
    vulkan-headers
    dxvk

    nvtopPackages.nvidia
  ];
}
