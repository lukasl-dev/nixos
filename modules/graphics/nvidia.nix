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
      enable = true; # TODO: configure power management
      finegrained = false;
    };

    open = true; # TODO: switch to open drivers
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
