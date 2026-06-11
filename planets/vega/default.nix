{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./audio.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelModules = [
      "nct6683"
      "nct6775"
      "coretemp"
    ];
    extraModprobeConfig = ''
      options nct6683 force=1
    '';
    kernel.sysctl = {
      "user.max_user_namespaces" = 15000;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiInstallAsRemovable = true;
      };
    };
    supportedFilesystems.ntfs = true;
  };

  planet = {
    name = "vega";
    timeZone = "Europe/Vienna";
    stateVersion = "25.05";

    hardware = {
      bluetooth.enable = true;

      nvidia = {
        enable = true;
        cuda = true;
      };
    };

    display = {
      enable = true;

      hyprland = {
        enable = true;
        monitors = [
          {
            output = "DP-1";
            mode = "1920x1080@239.96";
            position = "0x0";
            scale = 1;
          }
          {
            output = "HDMI-A-1";
            mode = "1920x1080@74.973";
            position = "1920x0";
            scale = 1;
          }
        ];
      };
    };

    programs = {
      anki.enable = true;
      uxplay.enable = true;
    };

    services = {
      flatpak.enable = true;
      printing.enable = true;
    };

    networking = {
      dns.discoverable = true;
      mullvad.enable = true;
    };

    gaming = {
      enable = true;

      steam.enable = true;
      minecraft.enable = true;
      r2modman.enable = true;
    };
  };

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

  nixpkgs.overlays = [
    (_final: prev: {
      coolercontrol = prev.coolercontrol // {
        coolercontrol-gui = prev.coolercontrol.coolercontrol-gui.overrideAttrs (old: {
          qtWrapperArgs = (old.qtWrapperArgs or [ ]) ++ [
            # CoolerControl is Qt WebEngine-based.  On Hyprland/NVIDIA its
            # Chromium view can fail to come up via Wayland/GBM, only logging:
            # "GBM is not supported ... Fallback to Vulkan rendering".
            # Run this app through XWayland and disable QtWebEngine GBM/GPU.
            # Note: CoolerControl overwrites QTWEBENGINE_CHROMIUM_FLAGS in its
            # own main(), so pass its built-in --disable-gpu CLI flag instead
            # of setting QTWEBENGINE_CHROMIUM_FLAGS in the wrapper.
            "--set"
            "QT_QPA_PLATFORM"
            "xcb"
            "--set"
            "QTWEBENGINE_FORCE_USE_GBM"
            "0"
            "--add-flags"
            "--disable-gpu"
          ];
        });
      };
    })
  ];
  programs.coolercontrol.enable = true;

  environment.systemPackages = [
    # nvidia/cuda build
    (pkgs.unstable.llama-cpp.override { cudaSupport = true; })

    # provides `hf download`
    (pkgs.python313.withPackages (ps: [
      ps.huggingface-hub
      ps.hf-transfer
    ]))
  ];

  environment.sessionVariables = {
    HF_HUB_ENABLE_HF_TRANSFER = "1";
  };
}
