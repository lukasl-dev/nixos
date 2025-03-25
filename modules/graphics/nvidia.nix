{
  pkgs,
  lib,
  config,
  ...
}:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement = {
      enable = false; # TODO: configure power management
      finegrained = false;
    };

    open = false; # TODO: switch to open drivers
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "570.86.16";
      sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
      openSha256 = lib.fakeSha256;
      settingsSha256 = "sha256-VUetj3LlOSz/LB+DDfMCN34uA4bNTTpjDrb6C6Iwukk=";
      sha256_aarch64 = lib.fakeSha256;
      persistencedSha256 = lib.fakeSha256;
    };
  };

  # environment.sessionVariables = {
  #   "LIBVA_DRIVER_NAME" = "nvidia";
  #   "GBM_BACKEND" = "nvidia-drm";
  #   "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
  #   "WLR_NO_HARDWARE_CURSORS" = "1";
  #   "__GL_GSYNC_ALLOWED" = "1";
  #   "__GL_VRR_ALLOWED" = "1";
  #   "__VK_LAYER_NV_optimus" = "NVIDIA_only";
  # };

  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
    vulkan-headers
    dxvk

    nvtopPackages.nvidia
  ];
}
