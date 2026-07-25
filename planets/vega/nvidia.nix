{ lib, ... }:

{
  # NVIDIA PRIME render offload: keep the AMD iGPU as the default renderer and
  # run selected programs on the RTX dGPU with `nvidia-offload <command>`.
  # Bus IDs from `lspci` on vega:
  #   01:00.0 NVIDIA GB203 [GeForce RTX 5070 Ti] -> PCI:1@0:0:0
  #   79:00.0 AMD Granite Ridge Radeon Graphics -> PCI:121@0:0:0
  services.xserver.videoDrivers = lib.mkForce [
    "amdgpu"
    "nvidia"
  ];

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    amdgpuBusId = "PCI:121@0:0:0";
    nvidiaBusId = "PCI:1@0:0:0";
  };

  # The shared NVIDIA module sets these globally for NVIDIA-primary systems.
  # For PRIME offload they must not force the session/compositor onto NVIDIA;
  # the generated `nvidia-offload` wrapper sets the required variables per app.
  environment.sessionVariables = {
    GBM_BACKEND = lib.mkForce null;
    __GLX_VENDOR_LIBRARY_NAME = lib.mkForce null;
    LIBVA_DRIVER_NAME = lib.mkForce null;
  };
}
